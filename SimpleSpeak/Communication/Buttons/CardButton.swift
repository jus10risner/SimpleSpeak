//
//  CardButton.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 12/18/24.
//

import UIKit
import SwiftUI

struct CardButton: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    @Binding var phraseToEdit: SavedPhrase?
    @ObservedObject var phrase: SavedPhrase
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            isPressed = true
            vm.speakImmediately(phrase.text)
            
            Task { await MultiButtonTip.didTapPhraseButton.donate() }  // Triggers the MultiButtonTip's appearance
            
            // Reset after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                vm.lastSpokenText = phrase.text
                isPressed = false
            }
        } label: {
            ZStack {
                Group {
                    if phrase.label != "" {
                        Text(phrase.label)
                            .font(containsOnlyEmoji ? .largeTitle : vm.selectedFont.name.bold())
                    } else {
                        Text(phrase.text)
                    }
                }
                .font(vm.selectedFont.name.bold())
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 100)
            }
            .background {
                RoundedRectangle(cornerRadius: vm.cornerRadius)
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .strokeBorder(phrase.color?.value ?? Color.clear, lineWidth: 3)
                    .opacity(isPressed ? 0.3 : 1)
            }
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                phraseToEdit = phrase
            } label: {
                Label("Edit Phrase", systemImage: "pencil")
                    .padding()
            }
        }
    }
    
    // Used to boost the size of emoji-only labels
    private var containsOnlyEmoji: Bool {
        phrase.label.allSatisfy { $0.isEmoji }
    }
}

extension Character {
    // Determines whether a given character is an emoji type
    var isEmoji: Bool {
        unicodeScalars.first?.properties.isEmojiPresentation == true ||
        unicodeScalars.first?.properties.isEmoji == true
    }
}

#Preview {
    let context = DataController.preview.container.viewContext
    let phrase = SavedPhrase(context: context)
    phrase.text = "Hello"
    
    return CardButton(phraseToEdit: .constant(nil), phrase: phrase)
        .environmentObject(ViewModel())
}

enum FontOption: String, CaseIterable, Identifiable {
    case small = "Small", medium = "Medium", large = "Large", xl = "Extra Large"
    var id: String { self.rawValue }
    
    var name: Font {
        switch self {
        case .small: return .subheadline
        case .medium: return .body
        case .large: return .title3
        case .xl: return .title2
        }
    }
    
    var textStyle: UIFont.TextStyle {
        switch self {
        case .small: return .subheadline
        case .medium: return .body
        case .large: return .title3
        case .xl: return .title2
        }
    }
}
