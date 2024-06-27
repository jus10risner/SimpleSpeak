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
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RecentPhrase.timeStamp_, ascending: false)]) var recentPhrases: FetchedResults<RecentPhrase>
    
    @State private var text = ""
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            recentPhrasesList
                .modifier(RemoveBackgroundColor())
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Recent Phrases")
                .listRowSpacing(5)
                .overlay { textInputField }
                .onAppear { vm.assignVoice() }
                .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        EditButton()
                    }
                    
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()

                        Button("Done") { isInputActive = false }
                    }
                }
        }
    }
    
    private var recentPhrasesList: some View {
        List {
            ForEach(recentPhrases, id: \.self) { phrase in
                Button {
                    vm.speak(phrase.text)
                } label: {
                    HStack {
                        Text(phrase.text)
                            .foregroundStyle(Color.primary)
                        
                        Spacer()
                        
                        Button {
                            // Save phrase to Saved Phrases
                            if !savedPhrases.contains(where: { phrase.text == $0.text }) {
                                let newPhrase = SavedPhrase(context: context)
                                newPhrase.text = phrase.text
                                
                                try? context.save()
                            }
                        } label: {
                            Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                removePhrases(at: indexSet)
                try? context.save()
            }
            .swipeActions(edge: .leading) {
                Button {
                    // TODO: Add to saved phrases
                } label: {
                    Label("Save Phrase", systemImage: "bookmark.fill")
                }
            }
        }
    }
    
    private var textInputField: some View {
        VStack {
            Spacer()
            
            Group {
                TextField("What would you like to say?", text: $text, axis: .vertical)
                    .lineLimit(5)
                    .font(.title2)
                    .padding(15)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 15))
                    .padding()
                    .background(.regularMaterial)
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
                        withAnimation(.easeInOut) {
                            submitAndAddRecent()
                        }
                    }
            }
            .ignoresSafeArea()
        }
        .toolbarBackground(.hidden, for: .tabBar)
    }
    
    func submitAndAddRecent() {
        isInputActive = true
        
        if text != "" {
            vm.speak(text)
            
            let newRecentPhrase = RecentPhrase(context: context)
            newRecentPhrase.text = text
            newRecentPhrase.timeStamp = Date()
            try? context.save()
            
            text = ""
        }
    }
    
    func removePhrases(at offsets: IndexSet) {
        for index in offsets {
            let phrase = recentPhrases[index]
            context.delete(phrase)
        }
    }
}

#Preview {
    CommunicationView()
        .environmentObject(ViewModel())
}
