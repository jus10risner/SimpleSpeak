//
//  CardButton.swift
//  Pipe Up
//
//  Created by Justin Risner on 12/18/24.
//

import SwiftUI

struct CardButton: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var phraseToEdit: SavedPhrase?
    let phrase: SavedPhrase
    
    @Namespace var animation
    
    var body: some View {
        Button {
            vm.cancelAndSpeak(phrase.text)
        } label: {
            ZStack {
                Group {
                    if phrase.label != "" {
                        Text(phrase.label)
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
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//            .background {
//                RoundedRectangle(cornerRadius: vm.cornerRadius)
//                    .fill(Color(.systemBackground))
//                    .overlay(RoundedRectangle(cornerRadius: vm.cornerRadius).stroke(lineWidth: 1))
//            }
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: vm.cornerRadius))
        }
        .matchedGeometryEffect(id: phrase.id, in: animation)
        .contextMenu {
            Button {
                phraseToEdit = phrase
            } label: {
                Label("Edit Phrase", systemImage: "pencil")
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let context = DataController.preview.container.viewContext
    let phrase = SavedPhrase(context: context)
    phrase.text = "Hello"
    
    return CardButton(phraseToEdit: .constant(nil), phrase: phrase)
        .environmentObject(ViewModel())
}
