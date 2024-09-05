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
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    
    @State private var selectedCategory: PhraseCategory?
    @State private var showingTextField = false
     
    @AppStorage("lastSelectedCategory") var lastSelectedCategory: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
//                    if categories.count > 0 {
                        CategorySelectorView(selectedCategory: $selectedCategory)
//                    }
                    
                    PhraseCardView(selectedCategory: $selectedCategory)
                }
            }
            .animation(.default, value: selectedCategory)
            .overlay {
                hoveringButtons
                    .animation(.default, value: vm.synthesizerState)
            }
//            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Speak")
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                if let lastSelectedCategory {
                    selectedCategory = categories.first(where: { $0.title == lastSelectedCategory })
                }
                
                vm.assignVoice()
            }
//            .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
            .onChange(of: selectedCategory) { category in
                lastSelectedCategory = category?.title
            }
        }
        .overlay {
            if showingTextField {
                TextInputView(showingTextField: $showingTextField)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
    
    private var hoveringButtons: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Group {
                    if vm.synthesizerState == .speaking {
                        HoveringButton(text: "Pause Speech", symbolName: "pause.fill") {
                            vm.pauseSpeaking()
                        }
                    } else if vm.synthesizerState == .paused {
                        HoveringButton(text: "Cancel Speech", symbolName: "stop.fill") {
                            vm.cancelSpeaking()
                        }
                        
                        HoveringButton(text: "Continue Speech", symbolName: "play.fill") {
                            vm.continueSpeaking()
                        }
                    } else {
                        HoveringButton(text: "Show Keyboard", symbolName: "keyboard.fill") {
                            showingTextField = true
                        }
                    }
                }
            }
            .padding()
        }
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
