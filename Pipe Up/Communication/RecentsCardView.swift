//
//  RecentsCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 11/12/24.
//

import SwiftUI

struct RecentsCardView: View {
    @Environment(\.managedObjectContext) var context
//    @EnvironmentObject var manager: HapticsManager
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: false)], predicate: NSPredicate(format: "category == %@", NSNull()), animation: .easeInOut) var recentPhrases: FetchedResults<SavedPhrase>
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    @Namespace var animation
//    @State private var animationEnabled = false
//    @State private var phraseToSpeak = ""
    
    @Binding var phraseToEdit: SavedPhrase?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(recentPhrases, id: \.id) { phrase in
                    CardButton(phraseToEdit: $phraseToEdit, phrase: phrase)
                        .matchedGeometryEffect(id: phrase.id, in: animation)
//                        .drawingGroup()
                    
//                    Button {
//                        vm.cancelAndSpeak(phrase)
////                    Menu {
////                        Button {
////                            phraseToEdit = phrase
////                        } label: {
////                            Label("Edit Phrase", systemImage: "pencil")
////                        }
//                        
////                        Button(role: .destructive) {
////                            context.delete(phrase)
////                            try? context.save()
////                        } label: {
////                            Label("Delete Phrase", systemImage: "trash")
////                        }
//                    } label: {
//                        ZStack {
//                            Text(phrase.text)
//                                .font(.headline)
//                                .minimumScaleFactor(0.9)
//                                .frame(maxWidth: .infinity)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                                .frame(height: 100)
//                        }
//                        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: vm.cornerRadius))
//                        .matchedGeometryEffect(id: phrase.id, in: animation)
//                        .drawingGroup()
////                        .scaleEffect(phraseToSpeak == phrase.text && vm.synthesizerState == .speaking ? 0.9 : 1)
//                    }
//                    .contextMenu {
//                        Button {
//                            phraseToEdit = phrase
//                        } label: {
//                            Label("Edit Phrase", systemImage: "pencil")
//                        }
//                    }
//                    .buttonStyle(.plain)
                }
            }
            .padding([.horizontal, .bottom])
            .animation(.default, value: recentPhrases.count)
        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                // Briefly prevents animation when view appears; only animates updates to Recents while the tab is active
//                animationEnabled = true
//            }
//        }
//        .onDisappear {
//            // Waits for 1 second before disabling animation on Recents tab; this prevents jumpy animation when navigating to another tab
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                animationEnabled = false
//            }
//        }
    }
}

#Preview {
    RecentsCardView(phraseToEdit: .constant(nil))
}
