//
//  TextInputView.swift
//  SimpleSpeak
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
    @State private var repeatableText = ""
    @State private var textFieldOpacity = 1.0
    @Binding var showingTextField: Bool
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
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
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                .padding()
                .background {
                    UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                        .fill(.ultraThinMaterial).ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .onAppear { isInputActive = true }
    }
    
    // MARK: - Views
    
    private var textField: some View {
        TextField("What would you like to say?", text: $text, axis: .vertical)
            .opacity(textFieldOpacity)
            .padding()
            .font(.title3)
            .focused($isInputActive)
            .submitLabel(.send)
            .onChange(of: text) { newValue in
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
                        text = repeatableText
                    }
                    
                    Task { await vm.speak(repeatableText) }
                }
                .transition(.opacity.animation(.default))
            }
            
            Spacer()
            
            speechControlButtons
                .transition(.opacity.animation(.default))
            
            if canClearText == true {
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
    
    // Determines whether the "Clear Text" button should be shown
    private var canClearText: Bool {
        if text != "" && vm.synthesizerState == .inactive {
            if text != repeatableText {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private var speechControlButtons: some View {
        Group {
            switch vm.synthesizerState {
            case .speaking:
                TextInputButton(text: "Pause Speech", symbolName: "pause.circle.fill") {
                    Task { await vm.pauseSpeaking() }
                }
            case .paused:
                TextInputButton(text: "Cancel Speech", symbolName: "stop.circle.fill", color: .red) {
                    Task { await vm.cancelSpeaking() }
                }
                
                TextInputButton(text: "Continue Speech", symbolName: "play.circle.fill") {
                    Task { await vm.continueSpeaking() }
                }
            case .inactive:
                EmptyView()
            }
        }
    }
    
    
    // MARK: - Methods
    
    func dismissKeyboard() {
        repeatableText = ""
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
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            Task { await  vm.speak(text) }
            
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
            
            isInputActive = true
            
            repeatableText = text
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
