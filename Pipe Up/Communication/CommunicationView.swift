//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @EnvironmentObject var haptics: HapticsManager
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
                topBar
                
                phraseCards
                
                bottomBar
            }
            .animation(.default, value: selectedCategory)
            .ignoresSafeArea(.keyboard)
            .toolbar(.hidden)
//            .background(Color(.secondarySystemBackground).ignoresSafeArea())
//            .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
            .task { await assignCategory() }
//            .onAppear { haptics.prepare() }
            .onChange(of: selectedCategory) { category in
                lastSelectedCategory = category?.title ?? "Recents"
            }
            .onChange(of: categories.count) { _ in
                if categories.count > 0 {
                    selectedCategory = categories.last
                } else {
                    selectedCategory = nil
                }
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
            Group {
                if showingTextField {
                    TextInputView(showingTextField: $showingTextField)
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: showingTextField)
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
    
    private var topBar: some View {
        HStack {
            if callObserver.isCallActive == true {
                callButton
            }
            
            speechSynthesisTextView
                .mask(Rectangle())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background {
            Rectangle()
                .fill(Color(.secondarySystemBackground).shadow(.drop(radius: 1)))
                .ignoresSafeArea()
        }
        .padding(.bottom, 1) // Makes just enough room for the drop shadow to be shown
    }
    
    private var phraseCards: some View {
        TabView(selection: $selectedCategory) {
            if categories.count == 0 && recentPhrases.count == 0 {
                EmptyCommunicationView(showingAddCategory: $showingAddCategory)
            } else {
                if recentPhrases.count > 0 {
                    RecentsCardView(phraseToEdit: $phraseToEdit)
                        .tag(PhraseCategory?(nil))
                }
                
                ForEach(categories) { category in
                    PhraseCardView(category: category, showingAddPhrase: $showingAddPhrase, phraseToEdit: $phraseToEdit)
                        .tag(category)
                }
            }
        }
        .id(recentPhrases.count < 1 ? recentPhrases.count : nil) // Prevents blink when RecentsCardView first appears
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var bottomBar: some View {
        VStack {
            CategorySelectorView(selectedCategory: $selectedCategory, showingAddCategory: $showingAddCategory)
            
            HStack {
                managePhrasesButton
                
                Spacer()
                
                MultiButtonView(showingTextField: $showingTextField)
                    .frame(width: 60) // Prevents the view from resizing when the symbols change, during speech synthesis
                
                Spacer()
                
                settingsButton
            }
            .padding(.horizontal)
        }
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity)
        .mask(Rectangle())
        .background {
            Rectangle()
                .fill(Color(.secondarySystemBackground).shadow(.drop(radius: 1)))
                .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // Check for safe area padding at the bottom, to determine if the device has a Home Button
    private var hasHomeButton: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return false }
                    
        return window.safeAreaInsets.bottom == 0
    }
    
    // Determine bottom padding, based on whether the device is an iPad; uses presence of Home Button, if not an iPad
    private var bottomPadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 20
        } else {
            return hasHomeButton ? 10 : 0
        }
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
        .mask { Rectangle() }
    }
    
    // Toolbar button that toggles the option to send speech synthesis to other parties on a call
    private var callButton: some View {
        Button {
            vm.useDuringCalls.toggle()
        } label: {
            Group {
                if vm.useDuringCalls == true {
                    Label("Use During Calls", systemImage: "phone.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.white, Color(.defaultAccent))
                } else {
                    Label("Use During Calls", systemImage: "speaker.wave.2.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .labelStyle(.iconOnly)
            .font(.title)
            .background {
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
                    animatingButton = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        animatingButton = false
                    }
                }
            }
        }
    }
    
    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Label("Settings", systemImage: "gearshape.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.largeTitle)
                .labelStyle(.iconOnly)
        }
    }
    
    private var managePhrasesButton: some View {
        Button {
            showingSavedPhrases = true
        } label: {
            Label("Manage Phrases", systemImage: "bookmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.largeTitle)
                .labelStyle(.iconOnly)
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
