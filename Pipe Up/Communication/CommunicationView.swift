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
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .ignoresSafeArea(.keyboard)
            .task { await assignCategory() }
            .onAppear {
                haptics.prepare()
                callObserver.objectWillChange.send() // Makes sure the view begins listening for changes to call status
            }
            .onChange(of: selectedCategory) { category in
                lastSelectedCategory = category?.title ?? "Recents"
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.useDuringCalls.toggle()
                    } label: {
                        Group {
                            if vm.useDuringCalls {
                                activeStateButtonLabel
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
    
    private var activeStateButtonLabel: some View {
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
//                if state == .speaking {
                if state == .speaking && callObserver.isCallActive == true { // Animate only during calls
                    animatingButton = true
                } else {
                    animatingButton = false
                }
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
