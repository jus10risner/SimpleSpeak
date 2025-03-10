//
//  CommunicationView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
//    @EnvironmentObject var haptics: HapticsManager
    @EnvironmentObject var vm: ViewModel
//    @StateObject private var callObserver = CallObserver()
    @StateObject var onboarding = OnboardingManager()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
    @State private var showingSettings = false
    @State private var showingSavedPhrases = false
    @State private var showingAddCategory = false
    @State private var showingAddPhrase = false
    @State private var phraseToEdit: SavedPhrase?
//    @State private var animatingButton = false
    @State private var showingDefaultCategoriesSelector = false
    @State private var disableButtonPresses = false
     
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
            .tint(Color(.defaultAccent)) // Prevents buttons from graying out, when onboarding tips are shown
            .ignoresSafeArea(.keyboard)
            .toolbar(.hidden)
            .allowsHitTesting(disableButtonPresses ? false : true)
            .task { await assignCategory() }
//            .onAppear { haptics.prepare() }
            .onAppear { onboarding.showWelcome() }
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
            .onChange(of: onboarding.currentStep) { newValue in
                if newValue == .complete {
                    onboarding.isComplete = true
                    print("Onboarding complete!")
                }
            }
            .onChange(of: recentPhrases.count) { newValue in
                if newValue == 0 && categories.count > 0 {
                    Task { @MainActor in
                        selectedCategory = categories.first
                    }
                }
            }
            .sheet(isPresented: $onboarding.isShowingWelcomeView, onDismiss: continueOnboarding, content: {
                WelcomeView()
            }).interactiveDismissDisabled()
            .sheet(isPresented: $showingDefaultCategoriesSelector, onDismiss: showOnboardingButtonTip, content: {
                DefaultCategoriesSelectorView(shouldShowHeader: true)
                    .presentationDetents([.medium])
            })
            .sheet(isPresented: $showingAddCategory, onDismiss: showOnboardingButtonTip, content: {
                AddCategoryView()
            })
            .sheet(isPresented: $showingAddPhrase, content: {
                AddSavedPhraseView(category: selectedCategory)
            })
            .sheet(item: $phraseToEdit, content: { phrase in
                EditSavedPhraseView(category: selectedCategory, savedPhrase: phrase, showCancelButton: true)
            })
            .sheet(isPresented: $showingSettings, content: {
                SettingsView()
            })
            .sheet(isPresented: $showingSavedPhrases, onDismiss: showOnboardingButtonTip, content: {
                CategoriesListView()
            })
        }
        .environmentObject(onboarding)
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
    
    // Sets selectedCategory when the app launches (based on lastSelectedCategory); prevents animation when selectedCategory is initially set
    func assignCategory() async {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            selectedCategory = categories.first(where: { $0.title == lastSelectedCategory }) ?? nil
        }
    }
    
    // Begin the onboarding process
    func continueOnboarding() {
        if #available(iOS 17, *) {
            vm.requestPersonalVoiceAccess()
        }
        
        onboarding.currentStep = .multiButton
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if categories.count > 0 {
//                onboarding.isShowingMultiButtonTip = true
//            }
//        }
    }
    
    // When appropriate, shows a popover tip to explain the MultiButton
    func showOnboardingButtonTip() {
        if onboarding.currentStep == .multiButton && categories.count > 0 {
            disableButtonPresses = true // Prevents popover from causing conflicts with other modals attempting to display
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onboarding.isShowingMultiButtonTip = true
            }
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
                .popover(isPresented: $onboarding.isShowingMultiButtonTip) {
                    PopoverTipView(symbolName: "sparkles", title: "One-button Control", text: "When idle, this button shows the keyboard; during speech, it controls phrase playback.")
                        .onDisappear {
                            onboarding.currentStep = .manageCategory
                            disableButtonPresses = false
                        }
                }
            
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
                Text("SimpleSpeak")
                    .font(.headline)
                    .transition(.asymmetric(insertion: .opacity.animation(.easeInOut), removal: .identity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 5)
//        .mask { Rectangle() }
    }
    
    // Toolbar button that toggles the option to send speech synthesis to other parties on a call
//    private var callButton: some View {
//        Button {
//            vm.useDuringCalls.toggle()
//        } label: {
//            Group {
//                if vm.useDuringCalls == true {
//                    Label("Use During Calls", systemImage: "phone.circle.fill")
//                        .symbolRenderingMode(.palette)
//                        .foregroundStyle(Color.white, Color(.defaultAccent))
//                } else {
//                    Label("Use During Calls", systemImage: "speaker.wave.2.circle.fill")
//                        .symbolRenderingMode(.hierarchical)
//                }
//            }
//            .labelStyle(.iconOnly)
//            .font(.title)
//            .background {
//                if vm.useDuringCalls {
//                    Circle()
//                        .stroke(Color(.defaultAccent))
//                        .scaleEffect(animatingButton ? 1.5 : 0.85)
//                        .opacity(animatingButton ? 0 : 1)
//                        .animation(animatingButton ? .easeInOut(duration: 1).repeatForever(autoreverses: false) : .linear(duration: 0), value: animatingButton)
//                }
//            }
//            .onChange(of: vm.synthesizerState) { state in
//                if state == .speaking {
//                    animatingButton = true
//                } else {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                        animatingButton = false
//                    }
//                }
//            }
//        }
//    }
    
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
            Label("Saved Phrases", systemImage: "bookmark.circle.fill")
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
