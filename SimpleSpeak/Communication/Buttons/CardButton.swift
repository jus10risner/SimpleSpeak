//
//  CardButton.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 12/18/24.
//

import SwiftUI

struct CardButton: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    @Binding var phraseToEdit: SavedPhrase?
    @ObservedObject var phrase: SavedPhrase
    
//    @Namespace var animation
    
    var body: some View {
        Button {
            vm.cancelAndSpeak(phrase.text)
        } label: {
            ZStack {
                Group {
                    if phrase.label != "" {
                        Text(phrase.label)
                            .font(isEmoji() ? .largeTitle : .headline)
                    } else {
                        Text(phrase.text)
                    }
                }
                .font(.headline)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 100)
            }
//            .drawingGroup()
//            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//            .background {
//                RoundedRectangle(cornerRadius: vm.cornerRadius)
//                    .fill(Color(.systemBackground))
//                    .overlay(RoundedRectangle(cornerRadius: vm.cornerRadius).stroke(lineWidth: 1))
//            }
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: vm.cornerRadius))
        }
//        .matchedGeometryEffect(id: phrase.id, in: animation)
        .contextMenu {
            Button {
                phraseToEdit = phrase
            } label: {
                Label("Edit Phrase", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                withAnimation {
                    context.delete(phrase)
                    try? context.save()
                }
            } label: {
                Label("Delete Phrase", systemImage: "trash")
            }
        }
        .buttonStyle(.plain)
    }
    
    func isEmoji() -> Bool {
        return phrase.label.contains { character in
            character.unicodeScalars.contains { $0.properties.isEmoji }
        }
    }
}

#Preview {
    let context = DataController.preview.container.viewContext
    let phrase = SavedPhrase(context: context)
    phrase.text = "Hello"
    
    return CardButton(phraseToEdit: .constant(nil), phrase: phrase)
        .environmentObject(ViewModel())
}
