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
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
     
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    @AppStorage("showingWelcomeView") var showingWelcomeView: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    speechSynthesisTextView
                    
                    CategorySelectorView(selectedCategory: $selectedCategory, showingAddCategory: $showingAddCategory)
                }
                .mask(RoundedRectangle(cornerRadius: vm.cornerRadius))
                .background {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .fill(Color(.secondarySystemBackground).shadow(.drop(radius: 1)))
                        .ignoresSafeArea(edges: .top)
                }
                .padding(.bottom, 1) // Makes just enough room for the drop shadow to be shown
                
                GeometryReader { geo in // This allows the ScrollView to resize as the device is rotated to landscape/portrait
                    ScrollView { // This, combined with the frame, allows the TabView to extend to the bottom of the screen
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
                        .frame(height: screenHeight)
                    }
                    .onChange(of: geo.size.height) { newValue in
                        withAnimation {
                            screenHeight = newValue
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .animation(.default, value: selectedCategory)
            .ignoresSafeArea(.keyboard)
            .overlay { customToolbar }
            .toolbar(.hidden)
//            .background(Color(.secondarySystemBackground).ignoresSafeArea())
//            .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
            .task { await assignCategory() }
//            .onAppear { haptics.prepare() }
            .onChange(of: selectedCategory) { category in
                lastSelectedCategory = category?.title ?? "Recents"
            }
            .onChange(of: categories.count) { _ in
                if categories.count == 1 && recentPhrases.count == 0 {
                    selectedCategory = categories.first
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
    
    private var customToolbar: some View {
        VStack {
            Spacer()
            
            ZStack {
                HStack {
                    callButton
                        .padding(5)
                        .background(.ultraThinMaterial, in: Circle())
                    
                    Spacer().frame(width: 250)
                }
                .opacity(callObserver.isCallActive ? 1 : 0)
                
                HStack {
                    managePhrasesButton
                    
                    Spacer().frame(width: 90)
                    
                    settingsButton
                }
                .padding(5)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(5)
                .overlay { HoveringButtonsView(showingTextField: $showingTextField) }
            }
        }
        .compositingGroup()
        .shadow(radius: 2)
        .padding(.bottom, bottomPadding)
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
//        .overlay {
//            RoundedRectangle(cornerRadius: vm.cornerRadius)
//                .stroke(Color.secondary, lineWidth: 1)
//        }
//        .mask { RoundedRectangle(cornerRadius: vm.cornerRadius) }
        .mask { Rectangle() }
        .padding(.horizontal)
        .padding(.vertical, 5)
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
            .font(.largeTitle)
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
    
    // Toolbar menu, containing settings and phrase management options
//    private var optionsMenu: some View {
//        Menu {
//            Button {
//                showingSavedPhrases = true
//            } label: {
//                Label("Manage Phrases", systemImage: "rectangle.grid.1x2")
//            }
//            
//            Button {
//                showingSettings = true
//            } label: {
//                Label("Settings", systemImage: "gearshape")
//            }
//        } label: {
//            Image(systemName: "ellipsis.circle.fill")
//                .symbolRenderingMode(.hierarchical)
//                .font(.title)
//        }
////        .padding(10)
////        .background(.ultraThinMaterial, in: Circle())
//    }
    
//    private var hoveringButtons: some View {
//        VStack {
//            Spacer()
//            
//            HoveringButtonsView(showingTextField: $showingTextField)
////                .padding(.vertical)
//                .frame(maxWidth: .infinity)
//                .background(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea().allowsHitTesting(false))
//        }
//        .ignoresSafeArea(.keyboard)
//    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CommunicationView()
        .environment(\.managedObjectContext, context)
        .environmentObject(HapticsManager())
        .environmentObject(ViewModel())
}
