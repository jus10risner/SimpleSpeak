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
    
    @State private var isShowingRecentsList = false
    @State private var selectedCategory: PhraseCategory?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextInputView()
                
                if categories.count > 0 {
                    CategorySelectorView(selectedCategory: $selectedCategory)
                }
                
                PhraseCardView(selectedCategory: $selectedCategory)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .onAppear { vm.assignVoice() }
            .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        isShowingRecentsList = true
                    } label: {
                        Label("Recently Used Phrases", systemImage: "clock.arrow.circlepath")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $isShowingRecentsList) {
                RecentPhrasesListView()
            }
        }
    }
}

#Preview {
    CommunicationView()
        .environmentObject(ViewModel())
}
