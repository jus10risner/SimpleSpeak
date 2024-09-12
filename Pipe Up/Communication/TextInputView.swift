//
//  TextInputView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/27/24.
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: true)]) var allPhrases: FetchedResults<SavedPhrase>
    
    @State private var text = ""
    @State private var mostRecentTypedPhrase = ""
    @Binding var showingTextField: Bool
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .environment(\.colorScheme, .dark)
            
            VStack(spacing: 0) {
                textFieldButtons
                
                textField
            }
            .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
            .padding()
        }
        .onAppear {
            isInputActive = true
        }
    }
    
    // MARK: - Views
    
    private var textField: some View {
        TextField("Type to speak...", text: $text, axis: .vertical)
            .padding([.horizontal, .bottom])
            .padding(.top, 10)
            .font(.title3)
            .focused($isInputActive)
            .submitLabel(.send)
            .onChange(of: text) { newValue in
                // This serves as a replacement for onSubmit, when a vertical axis is used on TextField
                guard let newValueLastCharacter = newValue.last else { return }
                if newValueLastCharacter == "\n" {
                    text.removeLast()
                    submitAndAddRecent()
                }
            }
            .onSubmit {
                // This serves to keep TextField focused if a hardware keyboard is used
                submitAndAddRecent()
            }
    }
    
    private var textFieldButtons: some View {
        HStack {
            if mostRecentTypedPhrase != "" && vm.synthesizerState == .inactive {
                TextInputButton(text: "Repeat Last Typed Phrase", symbolName: "repeat.circle.fill", action: {
                    vm.speak(mostRecentTypedPhrase)
                })
                .foregroundStyle(Color.secondary)
                .transition(.opacity.animation(.default))
            }
            
            Spacer()
            
            speechControlButtons
                .transition(.opacity.animation(.default))
            
            if text != "" {
                TextInputButton(text: "Clear Text", symbolName: "trash.circle.fill") {
                    withAnimation {
                        text = ""
                    }
                }
                .foregroundStyle(Color.secondary)
                .transition(.opacity.animation(.default))
            }
            
            TextInputButton(text: "Dismiss Keyboard", symbolName: "xmark.circle.fill") {
                dismissKeyboard()
            }
            .foregroundStyle(Color.secondary)
        }
        .padding([.top, .horizontal])
        .padding(.bottom, 0)
        .drawingGroup()
    }
    
    private var speechControlButtons: some View {
        Group {
            if vm.synthesizerState == .speaking {
                TextInputButton(text: "Pause Speech", symbolName: "pause.circle.fill") {
                    vm.pauseSpeaking()
                }
            } else if vm.synthesizerState == .paused {
                TextInputButton(text: "Cancel Speech", symbolName: "stop.circle.fill") {
                    vm.cancelSpeaking()
                }
                
                TextInputButton(text: "Continue Speech", symbolName: "play.circle.fill") {
                    vm.continueSpeaking()
                }
            }
        }
    }
    
    
    // MARK: - Methods
    
    func dismissKeyboard() {
        mostRecentTypedPhrase = ""
        isInputActive = false
        
        withAnimation {
            text = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                showingTextField = false
            }
        }
    }
    
    func submitAndAddRecent() {
        isInputActive = true
        
        if text != "" {
            vm.speak(text)
            
            // If phrase doesn't already exist in Recents, add it
            if !allPhrases.contains(where: { $0.category == nil && $0.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }) {
                let newSavedPhrase = SavedPhrase(context: context)
                newSavedPhrase.id = UUID()
                newSavedPhrase.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                newSavedPhrase.displayOrder = (allPhrases.last?.displayOrder ?? 0) + 1
                
                try? context.save()
            }
            
            mostRecentTypedPhrase = text
            
            withAnimation {
                text = ""
            }
        }
    }
}

#Preview {
    TextInputView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}
