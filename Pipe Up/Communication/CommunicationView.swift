//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var haptics: HapticsManager
    @EnvironmentObject var vm: ViewModel
    @StateObject private var callObserver = CallObserver()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
    @State private var showingSettings = false
    @State private var showingSavedPhrases = false
    @State private var showingAddCategory = false
    @State private var showingAddPhrase = false
    @State private var phraseToEdit: SavedPhrase?
    @State private var animatingButton = false
     
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    @AppStorage("showingWelcomeView") var showingWelcomeView: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                customToolbar
                    
                CategorySelectorView(selectedCategory: $selectedCategory, showingAddCategory: $showingAddCategory)
                
                Divider()
                
                TabView(selection: $selectedCategory) {
                    if recentPhrases.count > 0 {
                        RecentsCardView(phraseToEdit: $phraseToEdit)
                            .tag(PhraseCategory?(nil))
                    }
                    
                    ForEach(categories) { category in
                        PhraseCardView(category: category, showingAddPhrase: $showingAddPhrase, phraseToEdit: $phraseToEdit)
                            .tag(category)
                    }
                }
                .id(recentPhrases.count < 1 ? recentPhrases.count : nil) // Prevents blink when RecentsCardView first appears
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .animation(.default, value: selectedCategory)
            .overlay { hoveringButtons }
            .toolbar(.hidden)
//            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
            .ignoresSafeArea(.keyboard)
            .task { await assignCategory() }
            .onAppear { haptics.prepare() }
            .onChange(of: selectedCategory) { category in
                lastSelectedCategory = category?.title ?? "Recents"
            }
            .sheet(isPresented: $showingWelcomeView, onDismiss: {
                if #available(iOS 17, *) {
                    vm.requestPersonalVoiceAccess()
                }
            }, content: {
                WelcomeView()
            }).interactiveDismissDisabled()
            .sheet(isPresented: $showingAddCategory, content: {
                AddCategoryView()
            })
            .sheet(isPresented: $showingAddPhrase, content: {
                AddSavedPhraseView(category: selectedCategory)
            })
            .sheet(item: $phraseToEdit, content: { phrase in
                EditSavedPhraseView(category: selectedCategory, savedPhrase: phrase, showCancelButton: true)
            })
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingSavedPhrases) {
                CategoriesListView()
            }
        }
        .overlay {
            if showingTextField {
                TextInputView(showingTextField: $showingTextField)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
    
    // Sets selectedCategory when the app launches (based on lastSelectedCategory); prevents animation when selectedCategory is initially set
    func assignCategory() async {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            selectedCategory = categories.first(where: { $0.title == lastSelectedCategory }) ?? nil
        }
    }
    
    private var customToolbar: some View {
        HStack(alignment: .firstTextBaseline) {
            if callObserver.isCallActive == true {
                callButton
                
                Spacer()
            }
            
            speechSynthesisTextView
            
            Spacer()
            
            optionsMenu
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    private var speechSynthesisTextView: some View {
        VStack {
            if vm.synthesizerState != .inactive && showingTextField == false {
                Text(vm.label?.string ?? " ") // This ensures that the SpokenTextLabel's height matches that of the text
                    .opacity(0)
                    .overlay {
                        SpokenTextLabel(text: vm.label)
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                    }
                    .transition(.opacity.animation(.easeInOut))
            } else {
                Text("Tap a phrase to speak")
                    .foregroundStyle(Color(UIColor.placeholderText))
                    .transition(.asymmetric(insertion: .opacity.animation(.easeInOut), removal: .identity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .overlay {
            RoundedRectangle(cornerRadius: vm.cornerRadius)
                .stroke(Color.secondary)
        }
        .mask { RoundedRectangle(cornerRadius: vm.cornerRadius) }
    }
    
    // Toolbar button that toggles the option to send speech synthesis to other parties on a call
    private var callButton: some View {
        Button {
            vm.useDuringCalls.toggle()
        } label: {
            Label("Use During Calls", systemImage: vm.useDuringCalls ? "phone.circle.fill" : "speaker.wave.2.circle.fill")
                .labelStyle(.iconOnly)
                .symbolRenderingMode(vm.useDuringCalls ? .monochrome : .hierarchical)
                .font(.title2)
                .overlay {
                    if vm.useDuringCalls {
                        Circle()
                            .stroke(Color(.defaultAccent))
                            .scaleEffect(animatingButton ? 1.5 : 0.85)
                            .opacity(animatingButton ? 0 : 1)
                            .animation(animatingButton ? .easeInOut(duration: 1).repeatForever(autoreverses: false) : .linear(duration: 0), value: animatingButton)
                    }
                }
                .onChange(of: vm.synthesizerState) { state in
                    if state == .speaking {
//                    if state == .speaking && callObserver.isCallActive == true { // Animate only during calls
                        animatingButton = true
                    } else {
                        animatingButton = false
                    }
                }
        }
    }
    
    // Toolbar menu, containing settings and phrase management options
    private var optionsMenu: some View {
        Menu {
            Button {
                showingSavedPhrases = true
            } label: {
                Label("Manage Phrases", systemImage: "rectangle.grid.1x2")
            }
            
            Button {
                showingSettings = true
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.title2)
        }
    }
    
    private var hoveringButtons: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HoveringButtonsView(showingTextField: $showingTextField)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.8), Color(.systemBackground).opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea().allowsHitTesting(false))
        }
    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CommunicationView()
        .environment(\.managedObjectContext, context)
        .environmentObject(HapticsManager())
        .environmentObject(ViewModel())
}
