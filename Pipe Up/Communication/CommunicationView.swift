//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
    @EnvironmentObject var haptics: HapticsManager
    @EnvironmentObject var vm: ViewModel
    @StateObject private var callObserver = CallObserver()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
    @State private var showingSettings = false
    @State private var showingSavedPhrases = false
    @State private var showingAddPhrase = false
    @State private var phraseToEdit: SavedPhrase?
    @State private var animatingButton = false
//    @State private var animationAmount = 1.0
     
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    @AppStorage("showingWelcomeView") var showingWelcomeView: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                customToolbar
                
                CategorySelectorView(selectedCategory: $selectedCategory)
                
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
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .ignoresSafeArea(.keyboard)
            .task { await assignCategory() }
            .onAppear { haptics.prepare() }
            .onChange(of: selectedCategory) { category in
                lastSelectedCategory = category?.title ?? "Recents"
            }
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    callButton
//                }
//                
////                if verticalSizeClass == .compact {
////                    ToolbarItem(placement: .principal) {
////                        VStack {
////                            if vm.synthesizerState != .inactive && showingTextField == false {
////                                Text(vm.label?.string ?? " ") // This ensures that the SpokenTextLabel's height matches that of the text
////                                    .opacity(0)
////                                    .overlay { SpokenTextLabel(text: vm.label) }
////                                    .transition(.opacity)
////                            } else {
////                                Text("Tap a phrase to speak")
////                                    .font(.headline)
////                                    .foregroundStyle(Color.secondary)
////                            }
////                        }
////                        .frame(maxWidth: .infinity)
//////                        .padding()
//////                        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//////                        .padding(.horizontal)
////                    }
////                }
//                
//                ToolbarItem(placement: .topBarTrailing) {
//                    optionsMenu
//                }
//            }
            .sheet(isPresented: $showingWelcomeView, onDismiss: {
                if #available(iOS 17, *) {
                    vm.requestPersonalVoiceAccess()
                }
            }, content: {
                WelcomeView()
            }).interactiveDismissDisabled()
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
        HStack(alignment: .top) {
            callButton
            
            speechSynthesisTextView
                .padding(.top, 5)
            
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
            }
//            else {
//                Text("Tap a phrase to speak")
//                    .foregroundStyle(Color.secondary)
//            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: vm.synthesizerState)
//        .padding(.vertical, 5)
    }
    
    // Toolbar button that toggles the option to send speech synthesis to other parties on a call
    private var callButton: some View {
        Button {
            vm.useDuringCalls.toggle()
        } label: {
            Group {
                if vm.useDuringCalls {
                    callButtonLabel // symbol to use when option is enabled
                } else {
                    Image("phone.circle.slash.fill") // symbol to use when option is disabled
                }
            }
            .symbolRenderingMode(.hierarchical)
            .font(.title)
            .animation(.easeInOut, value: vm.useDuringCalls)
        }
        .accessibilityLabel("Use during calls")
    }
    
    // Label and animation to use when vm.useDuringCalls is true and a call is active
    private var callButtonLabel: some View {
        Image(systemName: "phone.circle.fill")
            .overlay {
                if callObserver.isCallActive == true {
                    ZStack {
                        Circle()
                            .stroke(Color(.defaultAccent))
                        
                        Circle()
                            .stroke(Color(.defaultAccent))
                            .scaleEffect(animatingButton ? 1.5 : 1.0)
                            .opacity(animatingButton ? 0 : 1)
                            .animation(animatingButton ? .easeInOut(duration: 0.75).repeatForever(autoreverses: false) : .linear(duration: 0),
                                       value: animatingButton
                            )
                    }
                }
            }
            .onChange(of: vm.synthesizerState) { state in
                if state == .speaking && callObserver.isCallActive == true { // Animate only during calls
                    animatingButton = true
                } else {
                    animatingButton = false
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
                .font(.title)
        }
    }
    
    private var hoveringButtons: some View {
        VStack {
            Spacer()
            
            HoveringButtonsView(showingTextField: $showingTextField)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground).opacity(0.8), Color(.secondarySystemBackground).opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea().allowsHitTesting(false))
//                .scaleEffect(animatingButton ? 1.1 : 1)
//                .animation(animatingButton ? .easeInOut.repeatForever(autoreverses: true) : .easeOut, value: animatingButton)
//                .onChange(of: vm.synthesizerState) { state in
//                    if state == .speaking {
//                        animatingButton = true
//                    } else {
//                        animatingButton = false
//                    }
//                }
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
