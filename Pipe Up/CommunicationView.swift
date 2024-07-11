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
    
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<PhraseCategory>
    @FetchRequest(sortDescriptors: []) var savedPhrases: FetchedResults<SavedPhrase>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \RecentPhrase.timeStamp_, ascending: false)]) var recentPhrases: FetchedResults<RecentPhrase>
    
    @State private var text = ""
    @FocusState var isInputActive: Bool
    
//    @State private var isEditing = false
    @State private var isShowingRecentsList = false
    @State private var selectedCategory: PhraseCategory?
    
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    let rows = [ GridItem(.adaptive(minimum: 150), spacing: 5) ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    textField
                    
                    scrollableGrid
                }
                
                vGridView
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .listRowSpacing(5)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .onAppear { vm.assignVoice() }
            .onChange(of: vm.usePersonalVoice) { _ in vm.assignVoice() }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        isShowingRecentsList = true
                    } label: {
                        Label("Recently Used Phrases", systemImage: "clock.arrow.circlepath")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $isShowingRecentsList) {
                RecentPhrasesListView()
            }
        }
    }
    
    private var scrollableGrid: some View {
//        VStack {
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing: 5) {
                    Button {
                        selectedCategory = nil
                    } label: {
                        Text("General")
                            .foregroundStyle(Color.primary)
                            .padding(15)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
                    }
                    .overlay {
                        if selectedCategory == nil {
                            RoundedRectangle(cornerRadius: vm.cornerRadius)
                                .stroke(Color.secondary, lineWidth: 0.5)
                        }
                    }
                    
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category.title)
                                .foregroundStyle(Color.primary)
                                .padding(15)
                                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
                        }
                        .overlay {
                            if selectedCategory == category {
                                RoundedRectangle(cornerRadius: vm.cornerRadius)
                                    .stroke(Color.secondary, lineWidth: 0.5)
                            }
                        }
                    }
                    
//                    ForEach(recentPhrases, id: \.self) { phrase in
//                        Button {
//                            vm.speak(phrase.text)
//                        } label: {
//                            HStack(spacing: 10) {
//                                Text(phrase.text)
//                                    .foregroundStyle(Color.primary)
//                                    .multilineTextAlignment(.leading)
//                                
//                                Spacer()
//                                
//                                Button {
//                                    // Save phrase to Saved Phrases
//                                    if !savedPhrases.contains(where: { phrase.text == $0.text }) {
//                                        let newPhrase = SavedPhrase(context: context)
//                                        newPhrase.text = phrase.text
//                                        
//                                        try? context.save()
//                                    }
//                                } label: {
//                                    Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
//                                        .labelStyle(.iconOnly)
//                                }
//                            }
//                            .padding(15)
//                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
//                        }
//                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            .padding(.bottom, 5)
            
//            Spacer()
//        }
    }
    
    private var textField: some View {
        VStack(spacing: 10) {
            TextField("Type here...", text: $text, axis: .vertical)
                .lineLimit(5)
                .font(.title3)
                .padding(15)
                .overlay {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .stroke(Color.secondary, lineWidth: 0.5)
                }
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
                    // This serves to keep TextField focused when a hardware keyboard is used
                    withAnimation(.easeInOut) {
                        submitAndAddRecent()
                    }
                }
            
            HStack {
                if isInputActive == true {
                    Button {
                        isInputActive = false
                    } label: {
                        Label("Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down")
                            .labelStyle(.iconOnly)
                            .font(.title)
                    }
                } else {
                    Button {
                        isInputActive = true
                    } label: {
                        Label("Show Keyboard", systemImage: "keyboard")
                            .labelStyle(.iconOnly)
                            .font(.title)
                    }
                }
                
                Spacer()
                
                if vm.isSpeaking {
                    stopSpeakingButton
                } else {
                    startSpeakingbutton
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    // Returns the phrases in the selected category
    private var filteredPhrases: [SavedPhrase] {
        return savedPhrases.filter({ $0.category == selectedCategory })
    }
    
    private var vGridView: some View {
        ScrollView {
//            VStack {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(filteredPhrases, id: \.self) { phrase in
                        Button {
                            vm.speak(phrase.text)
                        } label: {
                            HStack(spacing: 10) {
                                Text(phrase.text)
                                    .foregroundStyle(Color.primary)
                                    .frame(maxWidth: .infinity)
//                                    .multilineTextAlignment(.leading)
                                
//                                Spacer()
//                                
//                                VStack {
//                                    Button {
//                                        // Save phrase to Saved Phrases
//                                        if !savedPhrases.contains(where: { phrase.text == $0.text }) {
//                                            let newPhrase = SavedPhrase(context: context)
//                                            newPhrase.text = phrase.text
//                                            
//                                            try? context.save()
//                                        }
//                                    } label: {
//                                        Label("Save Phrase", systemImage: savedPhrases.contains(where: { phrase.text == $0.text }) ? "bookmark.fill" : "bookmark")
//                                            .labelStyle(.iconOnly)
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    Button(role: .destructive) {
//                                        withAnimation(.easeInOut) {
//                                            context.delete(phrase)
//                                            try? context.save()
//                                        }
//                                    } label: {
//                                        Label("Delete Phrase", systemImage: "trash")
//                                            .labelStyle(.iconOnly)
//                                    }
//                                    .opacity(isEditing ? 1 : 0)
//                                    .animation(.easeInOut(duration: 0.1), value: isEditing)
//                                }
                            }
                            .padding(20)
                            .frame(height: 100)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                        }
                    }
                }
                .padding()
                
//                Spacer()
//            }
//            .padding()
        }
    }
    
    private var stopSpeakingButton: some View {
        Button {
            vm.synthesizer.stopSpeaking(at: .immediate)
        } label: {
            Label("Stop Speaking", systemImage: "stop.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title)
        }
    }
    
    private var startSpeakingbutton: some View {
        Button {
            submitAndAddRecent()
        } label: {
            Label("Speak Text", systemImage: "play.circle.fill")
                .labelStyle(.iconOnly)
                .font(.title)
        }
    }
    
    func submitAndAddRecent() {
        isInputActive = true
        
        if text != "" {
            withAnimation(.easeInOut) {
                vm.speak(text)
                
                let newRecentPhrase = RecentPhrase(context: context)
                newRecentPhrase.text = text
                newRecentPhrase.timeStamp = Date()
                try? context.save()
                
                text = ""
            }
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
