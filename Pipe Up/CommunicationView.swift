//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<Phrase>
    
//    let synthesizer = AVSpeechSynthesizer()
    
    @State private var text = ""
    @State private var recentPhrases: [String] = []
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recentPhrases, id: \.self) { phrase in
                    Button {
                        vm.speak(phrase)
                    } label: {
                        HStack {
                            Text(phrase)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                            
                            Button {
                                // Save phrase to Saved Phrases
                                if !savedPhrases.contains(where: { phrase == $0.content }) {
                                    let newPhrase = Phrase(context: context)
                                    newPhrase.content = phrase
                                    
                                    try? context.save()
                                }
                            } label: {
                                Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase == $0.content }) ? "bookmark.fill" : "bookmark")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    recentPhrases.remove(atOffsets: indexSet)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        // TODO: Add to saved phrases
                    } label: {
                        Label("Save Phrase", systemImage: "bookmark.fill")
                    }
                }
            }
            .navigationTitle("Speak")
            .listRowSpacing(5)
            .overlay { textInputField }
            .onAppear { vm.assignVoice() }
            .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Toggle between recents and saved phrases(?)
                    } label: {
                        Label("Toggle", systemImage: "bookmark.circle.fill")
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") { isInputActive = false }
                }
            }
        }
    }
    
    private var textInputField: some View {
        VStack {
            Spacer()
            
            TextField("What would you like to say?", text: $text, axis: .vertical)
                .lineLimit(5)
                .font(.title2)
                .padding(15)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 15))
                .submitLabel(.send)
                .focused($isInputActive)
                .onChange(of: text) { newValue in
                    // This serves as a replacement for onSubmit, when a vertical axis is used on TextField
                    guard let newValueLastChar = newValue.last else { return }
                    if newValueLastChar == "\n" {
                        text.removeLast()
                        submitAndAddRecent()
                    }
                }
                .onSubmit {
                    // This serves to keep TextField focused when a hardware keyboard is used
                    submitAndAddRecent()
                }
        }
        .padding()
    }
    
    func submitAndAddRecent() {
        isInputActive = true
        vm.speak(text)
        recentPhrases.append(text)
        text = ""
    }
}

#Preview {
    CommunicationView()
}
