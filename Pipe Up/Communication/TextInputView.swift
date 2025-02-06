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
    @State private var textFieldOpacity = 1.0
    @Binding var showingTextField: Bool
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissKeyboard()
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    textFieldButtons
                    
                    textField
                }
                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                .padding()
            }
//            .transition(.move(edge: .bottom))
        }
        .onAppear { isInputActive = true }
    }
    
    // MARK: - Views
    
    private var textField: some View {
        TextField("What would you like to say?", text: $text, axis: .vertical)
            .opacity(textFieldOpacity)
//            .textInputAutocapitalization(.never)
            .padding()
            .font(.title3)
            .focused($isInputActive)
            .submitLabel(text.isEmpty ? .done : .send)
            .onChange(of: text) { newValue in
//                let firstLetter = newValue.prefix(1).capitalized
//                let remainingText = newValue.dropFirst()
//                text = firstLetter + remainingText
                // Serves as a replacement for onSubmit, when a vertical axis is used on TextField
                guard newValue.contains("\n") else { return }
                text = newValue.replacingOccurrences(of: "\n", with: "")
                Task { await submitAndAddRecent() }
            }
            .onSubmit {
                // Serves to keep TextField focused if a hardware keyboard is used
                Task { await submitAndAddRecent() }
            }
            .onChange(of: vm.synthesizerState) { state in
                if state == .inactive {
                    withAnimation {
                        textFieldOpacity = 1
                        text = ""
                    }
                } else {
                    withAnimation(.default.delay(0.1)) {
                        textFieldOpacity = 0
                    }
                }
            }
            .overlay {
                SpokenTextLabel(text: vm.label)
                    .padding()
                    .allowsHitTesting(false)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
    }
    
    private var textFieldButtons: some View {
        HStack {
            if vm.phraseIsRepeatable {
                TextInputButton(text: "Repeat Last Typed Phrase", symbolName: "repeat.circle.fill", color: .secondary) {
                    textFieldOpacity = 0
                    
                    withAnimation {
                        text = mostRecentTypedPhrase
                    }
                    
                    vm.speak(mostRecentTypedPhrase)
                }
                .transition(.opacity.animation(.default))
            }
            
            Spacer()
            
            speechControlButtons
                .transition(.opacity.animation(.default))
            
            if text != "" && vm.synthesizerState == .inactive {
                TextInputButton(text: "Clear Text", symbolName: "trash.circle.fill", color: .secondary) {
                    withAnimation {
                        text = ""
                    }
                }
                .transition(.opacity.animation(.default))
            }
            
            TextInputButton(text: "Dismiss Keyboard", symbolName: "xmark.circle.fill", color: .secondary) {
                dismissKeyboard()
            }
        }
        .padding(10)
        .drawingGroup()
    }
    
    private var speechControlButtons: some View {
        Group {
            switch vm.synthesizerState {
            case .speaking:
                TextInputButton(text: "Pause Speech", symbolName: "pause.circle.fill") {
                    vm.pauseSpeaking()
                }
            case .paused:
                TextInputButton(text: "Cancel Speech", symbolName: "stop.circle.fill", color: .red) {
                    vm.cancelSpeaking()
                }
                
                TextInputButton(text: "Continue Speech", symbolName: "play.circle.fill") {
                    vm.continueSpeaking()
                }
            case .inactive:
                EmptyView()
            }
        }
    }
    
    
    // MARK: - Methods
    
    func dismissKeyboard() {
        mostRecentTypedPhrase = ""
        vm.phraseIsRepeatable = false
        isInputActive = false
        
        withAnimation {
            text = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                showingTextField = false
            }
        }
    }
    
    func submitAndAddRecent() async {
        let recentPhrases = allPhrases.sorted(by: { $0.displayOrder > $1.displayOrder }).filter { $0.category == nil }
        
//        isInputActive = true
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            vm.speak(text)
            
            withAnimation {
                // If phrase doesn't already exist in Recents, add it
                if !recentPhrases.contains(where: { $0.text.normalized == text.normalized }) {
                    let newSavedPhrase = SavedPhrase(context: context)
                    newSavedPhrase.id = UUID()
                    newSavedPhrase.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    newSavedPhrase.displayOrder = (allPhrases.last?.displayOrder ?? 0) + 1
                    
                    if recentPhrases.count >= vm.numberOfRecents {
                        if let lastPhrase = recentPhrases.last {
                            context.delete(lastPhrase)
                        }
                    }
                    
                    try? context.save()
                }
            }
            
            mostRecentTypedPhrase = text
        } else {
            text = "" // Clears empty spaces from TextField
            dismissKeyboard()
        }
    }
}

#Preview {
    TextInputView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}

// Used for submitAndAddRecent(), to make sure strings are normalized before comparison
extension String {
    var normalized: String {
        self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
