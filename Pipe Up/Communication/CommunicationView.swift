//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject var vm = ViewModel()
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PhraseCategory.displayOrder, ascending: true)]) var categories: FetchedResults<PhraseCategory>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
    @State private var showingSettings = false
    @State private var showingSavedPhrases = false
    @State private var showingAddPhrase = false
    
//    @State private var selectedTab = "Recents"
     
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String = "Recents"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategorySelectorView(selectedCategory: $selectedCategory)
                
//                PhraseCardView(selectedCategory: $selectedCategory, showingAddPhrase: $showingAddPhrase)
                TabView(selection: $lastSelectedCategory) {
                    PhraseCardView(category: nil, showingAddPhrase: $showingAddPhrase)
                        .tag("Recents")
//
                    // Swiping between tabs should change the currently-selected category, to match the phrases that are visible
                    ForEach(categories) { category in
                        PhraseCardView(category: category, showingAddPhrase: $showingAddPhrase)
                            .tag(category.title)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .animation(.default, value: selectedCategory)
            .overlay {
                hoveringButtons
            }
//            .scrollDismissesKeyboard(.interactively)
//            .navigationTitle("Speak")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
//            .background(Color(.customBackground).ignoresSafeArea())
            .task { await assignCategory() }
            .onAppear { vm.assignVoice() }
            .onChange(of: lastSelectedCategory) { _ in
                withAnimation {
                    selectedCategory = categories.first(where: { $0.title == lastSelectedCategory })
                }
            }
//            .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
            .onChange(of: selectedCategory) { category in
                withAnimation {
                    lastSelectedCategory = category?.title ?? "Recents"
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingSavedPhrases = true
                        } label: {
                            Label("Manage Phrases", systemImage: "bookmark")
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddPhrase, content: {
                AddSavedPhraseView(category: selectedCategory)
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
        .environmentObject(vm)
    }
    
    func assignCategory() async {
        selectedCategory = categories.first(where: { $0.title == lastSelectedCategory })
    }
    
    private var hoveringButtons: some View {
        VStack {
            Spacer()
            
            HoveringButtonsView(showingTextField: $showingTextField)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Color(.systemGroupedBackground), Color(.systemGroupedBackground).opacity(0.8), Color(.systemGroupedBackground).opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea().allowsHitTesting(false))
        }
//        .animation(.default, value: vm.synthesizerState)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CommunicationView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
