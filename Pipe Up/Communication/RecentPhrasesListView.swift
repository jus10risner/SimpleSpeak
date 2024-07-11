//
//  RecentPhrasesListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/1/24.
//

import SwiftUI

struct RecentPhrasesListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RecentPhrase.timeStamp_, ascending: false)]) var recentPhrases: FetchedResults<RecentPhrase>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recentPhrases, id: \.self) { phrase in
                    Button {
                        vm.speak(phrase.text)
                    } label: {
                        HStack {
                            Text(phrase.text)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                            
                            Button {
                                // Save phrase to Saved Phrases
                                if !savedPhrases.contains(where: { phrase.text == $0.text }) {
                                    let newPhrase = SavedPhrase(context: context)
                                    newPhrase.text = phrase.text
                                    
                                    try? context.save()
                                }
                            } label: {
                                Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                .onDelete { indexSet in
                    removePhrases(at: indexSet)
                    try? context.save()
                }
//                .swipeActions(edge: .leading) {
//                    Button {
//                        // TODO: Add to saved phrases
//                    } label: {
//                        Label("Save Phrase", systemImage: "bookmark.fill")
//                    }
//                }
            }
            .navigationTitle("Recent Phrases")
            .navigationBarTitleDisplayMode(.inline)
            .listRowSpacing(5)
            .overlay {
                if recentPhrases.isEmpty {
                    ZStack {
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 10) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.secondary)
                            
                            VStack {
                                Text("No Recent Phrases")
                                    .font(.headline)
                                
//                                Text("Each phrase you type for the app to speak will appear here.")
//                                    .font(.caption)
//                                    .foregroundStyle(Color.secondary)
//                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 100)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if editMode?.wrappedValue == .active {
                        Button("Clear All") {
                            for item in recentPhrases {
                                context.delete(item)
                                try? context.save()
                            }
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .accessibilityLabel("Dismiss")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    func removePhrases(at offsets: IndexSet) {
        for index in offsets {
            let phrase = recentPhrases[index]
            context.delete(phrase)
        }
    }
}

#Preview {
    RecentPhrasesListView()
}
