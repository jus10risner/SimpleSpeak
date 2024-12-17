//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import SwiftUI

struct CommunicationView: View {
    @EnvironmentObject var manager: HapticsManager
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "category == %@", NSNull())) var recentPhrases: FetchedResults<SavedPhrase>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
    @State private var showingSettings = false
    @State private var showingSavedPhrases = false
    @State private var showingAddPhrase = false
    @State private var phraseToEdit: SavedPhrase?
    @State private var animatingButton = false
     
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
//                .ignoresSafeArea(edges: .bottom)
            }
            .animation(.default, value: selectedCategory)
//            .animation(.default, value: lastSelectedCategory)
            .overlay { hoveringButtons }
//            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
//            .scrollContentBackground(.hidden)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .ignoresSafeArea(.keyboard)
            .task { await assignCategory() }
            .onAppear { manager.prepareHaptics() }
//            .onAppear {
//                if #available(iOS 17, *) {
//                    vm.fetchPersonalVoices()
//                }
                
//                vm.assignVoice()
//            }
//            .onChange(of: lastSelectedCategory) { _ in
////                withAnimation {
//                    selectedCategory = categories.first(where: { $0.title == lastSelectedCategory })
//                print("changed selectedCategory")
////                }
//            }
            .onChange(of: selectedCategory) { category in
//                withAnimation {
                    lastSelectedCategory = category?.title ?? "Recents"
//                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.useDuringCalls.toggle()
                    } label: {
                        Group {
                            if vm.useDuringCalls {
                                Image(systemName: "phone.circle.fill")
                            } else {
                                Image("phone.circle.slash.fill")
                            }
                        }
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                        .animation(.easeInOut, value: vm.useDuringCalls)
                    }
                    .accessibilityLabel("Use during calls")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
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
            }
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
    
    private var hoveringButtons: some View {
        VStack {
            Spacer()
            
            HoveringButtonsView(showingTextField: $showingTextField)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground).opacity(0.8), Color(.secondarySystemBackground).opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea().allowsHitTesting(false))
                .scaleEffect(animatingButton ? 1.1 : 1)
                .animation(animatingButton ? .easeInOut.repeatForever(autoreverses: true) : .easeOut, value: animatingButton)
                .onChange(of: vm.synthesizerState) { state in
                    if state == .speaking {
                        animatingButton = true
                    } else {
                        animatingButton = false
                    }
                }
        }
//        .padding(.bottom, hasHomeButton ? 10 : 0)
//        .ignoresSafeArea(.keyboard)
    }
    
//    // Checks safe area insets, to determine if bottom padding is needed
//    private var hasHomeButton: Bool {
//        let scenes = UIApplication.shared.connectedScenes
//        let windowScene = scenes.first as? UIWindowScene
//        guard let window = windowScene?.windows.first else { return false }
//        
//        return window.safeAreaInsets.bottom == 0
//    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CommunicationView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
