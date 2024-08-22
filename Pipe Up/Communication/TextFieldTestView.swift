//
//  TextFieldTestView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/22/24.
//

import SwiftUI

struct TextFieldTestView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: true)]) var allPhrases: FetchedResults<SavedPhrase>
    
    @State private var text = ""
    @FocusState var isInputActive: Bool
    
    var body: some View {
        GroupBox {
//            VStack(spacing: 15) {
//                GroupBox {
                    TextField("Type here...", text: $text, axis: .vertical)
                        .lineLimit(5)
                        .font(.title3)
                        .focused($isInputActive)
                        .submitLabel(.send)
                        .onChange(of: text) { newValue in
                            // This serves as a replacement for onSubmit, when a vertical axis is used on TextField
                            guard let newValueLastChar = newValue.last else { return }
                            if newValueLastChar == "\n" {
                                text.removeLast()
                                submitAndAddRecent()
                                
                            }
                        }
                        .onSubmit {
                            // This serves to keep TextField focused if a hardware keyboard is used
                            withAnimation(.easeInOut) {
                                submitAndAddRecent()
                            }
                    }
//                }
                
//                Button {
//                    isInputActive.toggle()
//                } label: {
//                    if isInputActive {
//                        Label("Hide Keyboard", systemImage: "keyboard.chevron.compact.down")
//                    } else {
//                        Label("Show Keyboard", systemImage: "keyboard")
//                    }
//                }
//            }
        }
        .padding()
    }
    
    func submitAndAddRecent() {
        isInputActive = true
        
        if text != "" {
            withAnimation(.easeInOut) {
                vm.speak(text)
                
                // If phrase doesn't already exist in Recents, add it
                if !allPhrases.contains(where: { $0.category == nil && $0.text == text }) {
                    let newSavedPhrase = SavedPhrase(context: context)
                    newSavedPhrase.id = UUID()
                    newSavedPhrase.text = text
                    newSavedPhrase.displayOrder = (allPhrases.last?.displayOrder ?? 0) + 1
                    try? context.save()
                }
                
                text = ""
            }
        }
    }
}

#Preview {
    TextFieldTestView()
}
