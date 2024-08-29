//
//  TextInputView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/27/24.
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: true)]) var allPhrases: FetchedResults<SavedPhrase>
    
    @State private var text = ""
    @State private var mostRecentTypedPhrase = ""
    @State private var showingTextFieldButtons = false
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if showingTextFieldButtons {
                textFieldButtons
            }
            
            textField
        }
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
        .padding()
        .onChange(of: isInputActive) { bool in
            withAnimation(.snappy) {
                showingTextFieldButtons = bool
            }
        }
    }
    
    // MARK: - Views
    
    private var textField: some View {
        TextField("Tap to type...", text: $text, axis: .vertical)
            .padding()
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
    }
    
    private var textFieldButtons: some View {
        HStack {
            repeatPhraseButton
                .opacity(mostRecentTypedPhrase == "" ? 0 : 1)
            
            Spacer()
            
//            if vm.synthesizerState == .speaking {
//                pauseSpeakingButton
//            } else if vm.synthesizerState == .paused {
//                cancelSpeakingButton
//
//                continueSpeakingButton
//            }
            
//            clearTextButton
//                .opacity(text == "" ? 0 : 1)
//                .animation(.easeInOut, value: text)
            
            dismissTextFieldButton
        }
        .padding(10)
    }
    
    
    // MARK: - Buttons
    
    private var dismissTextFieldButton: some View {
        Button {
            withAnimation {
                text = ""
                mostRecentTypedPhrase = ""
                vm.cancelSpeaking()
                isInputActive = false
            }
        } label: {
            Label("Dismiss Keyboard", systemImage: "xmark.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title)
                .foregroundStyle(Color.secondary)
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
    }
    
    private var clearTextButton: some View {
        Button {
            text = ""
        } label: {
            Label("Clear Text", systemImage: "trash.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title)
                .foregroundStyle(Color.secondary)
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
    }
    
    private var repeatPhraseButton: some View {
        Button {
            vm.speak(mostRecentTypedPhrase)
        } label: {
            Label("Speak Last Typed Phrase", systemImage: "repeat.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title)
                .foregroundStyle(Color.secondary)
                .symbolRenderingMode(.hierarchical)
        }
        .buttonStyle(.plain)
    }
    
    
    // MARK: - Methods
    
    func submitAndAddRecent() {
        isInputActive = true
        
        if text != "" {
            mostRecentTypedPhrase = text
            
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
    TextInputView()
        .environmentObject(ViewModel())
}
