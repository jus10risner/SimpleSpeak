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
            Color.black
                .opacity(0.5)
//            Color.clear
//                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissKeyboard()
                }
//                .transition(.opacity.animation(.easeInOut))
//                .environment(\.colorScheme, .dark)
            
            VStack(spacing: 0) {
                textFieldButtons
                
                textField
            }
//            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: vm.cornerRadius))
            .padding()
            .transition(.move(edge: .bottom))
        }
        .onAppear { isInputActive = true }
    }
    
    // MARK: - Views
    
    private var textField: some View {
        TextField("What would you like to say?", text: $text, axis: .vertical)
            .padding([.horizontal, .bottom])
            .padding(.top, 10)
            .font(.title3)
            .focused($isInputActive)
            .submitLabel(.send)
            .onChange(of: text) { newValue in
                // Serves as a replacement for onSubmit, when a vertical axis is used on TextField
                let returnButtonTapped = newValue.contains("\n")
                
                if returnButtonTapped {
                    text = newValue.filter({ $0 != "\n" })
                    Task { await submitAndAddRecent()}
                }
            }
            .onSubmit {
                // Serves to keep TextField focused if a hardware keyboard is used
                Task { await submitAndAddRecent() }
            }
    }
    
    private var textFieldButtons: some View {
        HStack {
            if vm.phraseIsRepeatable {
                TextInputButton(text: "Repeat Last Typed Phrase", symbolName: "repeat.circle.fill", color: .secondary) {
                    vm.speak(mostRecentTypedPhrase)
                }
                .transition(.opacity.animation(.default))
            }
            
            Spacer()
            
            speechControlButtons
                .transition(.opacity.animation(.default))
            
            if text != "" {
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
//        .padding([.top, .horizontal], 5)
//        .padding(.bottom, 10)
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
        let textToSpeak = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let recentPhrases = allPhrases.sorted(by: { $0.displayOrder > $1.displayOrder }).filter { $0.category == nil }
        
        isInputActive = true
        
        if textToSpeak != "" {
            vm.speak(text)
            
            // If phrase doesn't already exist in Recents, add it
            if !recentPhrases.contains(where: { $0.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == textToSpeak }) {
                let newSavedPhrase = SavedPhrase(context: context)
                newSavedPhrase.id = UUID()
                newSavedPhrase.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                newSavedPhrase.displayOrder = (allPhrases.last?.displayOrder ?? 0) + 1
                
                if recentPhrases.count >= vm.numberOfRecents {
                    context.delete(recentPhrases.last ?? recentPhrases[vm.numberOfRecents])
                }
                
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
