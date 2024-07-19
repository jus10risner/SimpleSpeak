//
//  RecentPhrasesListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 7/1/24.
//

import CoreData
import SwiftUI

struct RecentPhrasesListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: true)]) var savedPhrases: FetchedResults<SavedPhrase>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RecentPhrase.timeStamp_, ascending: false)]) var recentPhrases: FetchedResults<RecentPhrase>
    
    @State private var isEditing = false
    @State private var selection = Set<RecentPhrase>()
    
    var body: some View {
        NavigationStack {
            List(selection: $selection) {
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
                                    newPhrase.displayOrder = (savedPhrases.last?.displayOrder ?? 0) + 1
                                    
                                    try? context.save()
                                }
                            } label: {
                                Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            context.delete(phrase)
                            try? context.save()
                        } label: {
                            Label("Delete Phrase", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.red)
                    }
                }
//                .onDelete(perform: { indexSet in
//                    vm.deletePhrase(at: indexSet, from: recentPhrases)
//                })
            }
            .navigationTitle("Recent Phrases")
            .navigationBarTitleDisplayMode(.inline)
            .listRowSpacing(vm.listRowSpacing)
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
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityLabel("Dismiss")
                    }
                }
                
                if !recentPhrases.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }
                    }
                }
                
                if isEditing == true {
                    ToolbarItemGroup(placement: .bottomBar) {
                        if selection.isEmpty {
                            Button("Clear All") {
                                for item in recentPhrases {
                                    context.delete(item)
                                    try? context.save()
                                }
                            }
                        } else {
                            Button("Delete", role: .destructive) {
                                withAnimation {
                                    for item in selection {
                                        context.delete(item)
                                        try? context.save()
                                    }
                                }
                                
                                selection = Set()
                            }
                            .tint(Color.red)
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
        }
    }
}

#Preview {
    RecentPhrasesListView()
        .environmentObject(ViewModel())
}
