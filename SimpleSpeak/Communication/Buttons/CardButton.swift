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
    
    @State private var showingEditButton: Bool = false
    
    var body: some View {
        Button {
            vm.speakImmediately(phrase.text)
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
                .foregroundStyle(Color.primary)
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
            }
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: vm.cornerRadius))
        }
        .buttonStyle(.borderless)
        .highPriorityGesture(LongPressGesture().onEnded { _ in
            showingEditButton = true
        })
        .popover(isPresented: $showingEditButton) {
            Button {
                print(phrase.text)
                phraseToEdit = phrase
            } label: {
                Label("Edit Phrase", systemImage: "pencil")
            }
            .padding()
            .presentationBackground(.regularMaterial)
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "More Actions") {
            showingEditButton = true
        }
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
