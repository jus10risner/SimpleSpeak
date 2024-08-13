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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    TextInputView()
                    
//                    if categories.count > 0 {
                        CategorySelectorView(selectedCategory: $selectedCategory)
//                    }
                    
                    PhraseCardView(selectedCategory: $selectedCategory)
                    
                    Divider()
                        .frame(width: 0)
                }
            }
            .scrollDismissesKeyboard(.interactively)
//            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .onAppear { vm.assignVoice() }
            .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if vm.isSpeaking {
                        pauseSpeakingButton
                    } else {
                        continueSpeakingButton
                    }
                }
            }
        }
    }
    
    private var pauseSpeakingButton: some View {
        Button {
            vm.pauseSpeaking()
        } label: {
            Label("Pause Speech", systemImage: "pause.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title2)
        }
    }
    
    private var continueSpeakingButton: some View {
        Button {
            vm.continueSpeaking()
        } label: {
            Label("Continue Speech", systemImage: "play.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title2)
        }
    }
}

#Preview {
    let controller = DataController(inMemory: true)
    let context = controller.container.viewContext
    
    return CommunicationView()
        .environment(\.managedObjectContext, context)
        .environmentObject(ViewModel())
}
