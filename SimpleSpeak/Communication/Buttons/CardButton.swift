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
    
    @State private var isPressed = false
    
    var body: some View {
        Menu {
            Button {
                print(phrase.text)
                phraseToEdit = phrase
            } label: {
                Label("Edit Phrase", systemImage: "pencil")
            }
        } label: {
            ZStack {
                Group {
                    if phrase.label != "" {
                        Text(phrase.label)
                            .font(containsOnlyEmoji ? .largeTitle : vm.selectedFont.name)
                    } else {
                        Text(phrase.text)
                    }
                }
                .font(vm.selectedFont.name)
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
        } primaryAction: {
            isPressed = true
            vm.speakImmediately(phrase.text)
            
            Task { await MultiButtonTip.didTapPhraseButton.donate() }  // Triggers the MultiButtonTip's appearance
            
            // Reset after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }
        .buttonStyle(.plain)
    }
    
    private var containsOnlyEmoji: Bool {
        return phrase.label.unicodeScalars.allSatisfy { $0.properties.isEmoji }
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
        case .small: return .subheadline.bold()
        case .medium: return .headline
        case .large: return .title3.bold()
        case .xl: return .title2.bold()
        }
    }
}
