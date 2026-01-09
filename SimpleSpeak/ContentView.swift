//
//  ContentView.swift
//  QuickSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
    @State private var showingSettings = false
    @State private var showingSavedPhrases = false
    @State private var showingAddCategory = false
    @State private var showingAddPhrase = false
    @State private var phraseToEdit: SavedPhrase?
    @State private var showingDefaultCategoriesSelector = false
    @State private var onboardingSheet: ActiveOnboardingSheet?
     
    @AppStorage("savedAppVersion") var savedAppVersion: String = "" // Used to determine onboarding view to show
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                topBar
                
                phraseCards
                
                bottomBar
            }
            .accessibilityHidden(showingTextField ? true : false)
            .animation(.default, value: selectedCategory)
            .ignoresSafeArea(.keyboard)
            .toolbar(.hidden)
            .onAppear {
                checkForOnboardingViewsToShow()
            }
            .task {
                await assignCategory()
                
                if onboardingSheet != .welcome { // Prevents interference with fetching Personal Voice
                    await vm.checkSpeechVoice()
                }
            }
            .onChange(of: selectedCategory) { _, category in
                lastSelectedCategory = category?.title ?? "Recents"
            }
            .onChange(of: categories.count) {
                selectedCategory = categories.last ?? nil
            }
            .onChange(of: recentPhrases.count) { _, newValue in
                if newValue == 0 && categories.count > 0 {
                    Task { @MainActor in
                        selectedCategory = categories.first
                    }
                }
            }
            .sheet(item: $onboardingSheet, content: { sheet in
                switch sheet {
                case .welcome:
                    WelcomeView(onboardingSheet: $onboardingSheet)
                        .onDisappear {
                            savedAppVersion = AppInfo().version
                            vm.requestPersonalVoiceAccess()
                        }
                case .whatsNew:
                    WhatsNewView()
                        .onDisappear {
                            savedAppVersion = AppInfo().version
                        }
                }
            })
            .sheet(isPresented: $showingDefaultCategoriesSelector, content: {
                DefaultCategoriesSelectorView()
                    .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
            })
            .sheet(isPresented: $showingAddCategory, content: {
                AddEditCategoryView()
            })
            .sheet(isPresented: $showingAddPhrase, content: {
                NavigationStack {
                    AddEditPhraseView(category: selectedCategory, showCancelButton: true)
                }
            })
            .sheet(item: $phraseToEdit, content: { phrase in
                NavigationStack {
                    AddEditPhraseView(category: selectedCategory, savedPhrase: phrase, showCancelButton: true)
                }
            })
            .sheet(isPresented: $showingSettings, content: {
                SettingsView()
            })
            .sheet(isPresented: $showingSavedPhrases, content: {
                CategoriesListView()
            })
        }
        .overlay {
            Group {
                if showingTextField {
                    TextInputView(showingTextField: $showingTextField)
                } else {
                    EmptyView()
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: showingTextField)
        }
    }
    
    // Determines whether (and which) onboarding view should be displayed
    private func checkForOnboardingViewsToShow() {
        let currentAppVersion = AppInfo().version
        let lastRunAppVersion = savedAppVersion
        
        if savedAppVersion.isEmpty {
            onboardingSheet = .welcome
            print("Showing Welcome view")
        } else if lastRunAppVersion != currentAppVersion {
            onboardingSheet = .whatsNew
            print("Showing What's New view")
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
        VStack(spacing: 0) {
            speechSynthesisTextView
                .mask(Rectangle())
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            CategorySelectorView(selectedCategory: $selectedCategory, showingAddCategory: $showingAddCategory)
        }
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
                EmptyCommunicationView(showingAddCategory: $showingAddCategory, showingDefaultCategoriesSelector: $showingDefaultCategoriesSelector)
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
        HStack {
            savedPhrasesButton
            
            Spacer()
            
            MultiButtonView(showingTextField: $showingTextField)
                .frame(width: 60) // Prevents the view from resizing when the symbols change, during speech synthesis
                .popoverTip(MultiButtonTip())
            
            Spacer()
            
            settingsButton
        }
        .padding(.horizontal)
        .padding(.bottom, bottomPadding)
        .padding(.top, 10)
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
                    .foregroundStyle(Color.secondary)
                    .transition(.asymmetric(insertion: .opacity.animation(.easeInOut), removal: .identity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 5)
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
    
    private var savedPhrasesButton: some View {
        Button {
            showingSavedPhrases = true
        } label: {
            Label("Manage Categories", systemImage: "bookmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.largeTitle)
                .labelStyle(.iconOnly)
        }
    }
}

enum ActiveOnboardingSheet: String, Identifiable {
    case welcome, whatsNew
    
    var id: String { rawValue }
}

#Preview {
    ContentView()
        .environmentObject(ViewModel())
}
