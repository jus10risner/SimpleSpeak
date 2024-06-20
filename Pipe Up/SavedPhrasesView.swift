//
//  SavedPhrasesView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import SwiftUI

struct SavedPhrasesView: View {
    @EnvironmentObject var vm: ViewModel
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<Phrase>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(savedPhrases) { phrase in
                    Button {
                        vm.speak(phrase.content)
                    } label: {
                        Text(phrase.content)
                            .foregroundStyle(Color.primary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            context.delete(phrase)
                            try? context.save()
                        } label: {
                            Label("Delete Phrase", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                        .tint(Color.red)
                    }
                }
            }
            .listRowSpacing(5)
            .navigationTitle("Saved Phrases")
        }
    }
}

#Preview {
    SavedPhrasesView()
}
