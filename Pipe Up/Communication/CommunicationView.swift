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
    
//    @State private var isShowingRecentsList = false
    @State private var selectedCategory: PhraseCategory?
    @State private var showingRecents = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    TextInputView()
                    
//                    if categories.count > 0 {
                        CategorySelectorView(selectedCategory: $selectedCategory, showingRecents: $showingRecents)
//                    }
                    
                    PhraseCardView(selectedCategory: $selectedCategory, showingRecents: $showingRecents)
                    
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
//                ToolbarItemGroup(placement: .topBarLeading) {
//                    Button {
//                        isShowingRecentsList = true
//                    } label: {
//                        Label("Recently Used Phrases", systemImage: "clock.arrow.circlepath")
//                            .labelStyle(.iconOnly)
//                    }
//                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if vm.isSpeaking {
                        pauseSpeakingButton
                    } else {
                        continueSpeakingButton
                    }
                }
            }
//            .sheet(isPresented: $isShowingRecentsList) {
//                RecentPhrasesListView()
//            }
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
    CommunicationView()
        .environmentObject(ViewModel())
}
