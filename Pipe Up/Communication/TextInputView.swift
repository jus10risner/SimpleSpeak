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
    
    @State private var text = ""
    @FocusState var isInputActive: Bool
    
    var body: some View {
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
                    // This serves to keep TextField focused if a hardware keyboard is used
                    withAnimation(.easeInOut) {
                        submitAndAddRecent()
                    }
                }
            
//            HStack(alignment: .top) {
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
                
//                Spacer()
                
//                if vm.isSpeaking {
//                    pauseSpeakingButton
//                } else {
//                    continueSpeakingButton
//                }
                
//                if vm.isSpeaking {
//                    stopSpeakingButton
//                } else {
//                    startSpeakingButton
//                }
//            }
//            .padding(.horizontal)
        }
        .padding()
    }
    
//    private var startSpeakingButton: some View {
//        Button {
//            submitAndAddRecent()
//        } label: {
//            Label("Speak Text", systemImage: "play.circle.fill")
//                .labelStyle(.iconOnly)
//                .font(.largeTitle)
//        }
//    }
//    
//    private var stopSpeakingButton: some View {
//        Button {
//            vm.stopSpeaking()
//        } label: {
//            Label("Speak Text", systemImage: "stop.circle.fill")
//                .labelStyle(.iconOnly)
//                .font(.largeTitle)
//        }
//    }
//    
//    private var pauseSpeakingButton: some View {
//        Button {
//            vm.pauseSpeaking()
//        } label: {
//            Label("Pause Speech", systemImage: "pause.circle.fill")
//                .labelStyle(.iconOnly)
//                .font(.largeTitle)
//        }
//    }
//    
//    private var continueSpeakingButton: some View {
//        Button {
//            vm.continueSpeaking()
//        } label: {
//            Label("Continue Speech", systemImage: "play.circle.fill")
//                .labelStyle(.iconOnly)
//                .font(.largeTitle)
//        }
//    }
    
    func submitAndAddRecent() {
        isInputActive = true
        
        if text != "" {
            withAnimation(.easeInOut) {
                vm.speak(text)
                
                let newRecentPhrase = RecentPhrase(context: context)
                newRecentPhrase.id = UUID()
                newRecentPhrase.text = text
                newRecentPhrase.timeStamp = Date()
                try? context.save()
                
                text = ""
            }
        }
    }
}

#Preview {
    TextInputView()
        .environmentObject(ViewModel())
}
