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
    
    @Binding var text: String
    @FocusState.Binding var isInputActive: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                if isInputActive {
                    HStack {
                        Spacer()
                        
                        Button {
                            isInputActive = false
                        } label: {
                            Label("Dismiss Keyboard", systemImage: "xmark.circle.fill")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(Color.secondary)
                                .font(.title2)
                        }
                        .padding([.top, .trailing], 10)
                    }
                }
                
                HStack {
                    TextField("Type here...", text: $text, axis: .vertical)
                        .lineLimit(5)
                        .font(.title2)
                        .padding(15)
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
                    
//                    VStack {
//                        
//                        
//                        Button {
//                            text = ""
//                        } label: {
//                            Image(systemName: "trash")
//                        }
//                    }
                }
            }
//            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: vm.cornerRadius))
//            .overlay {
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.secondary, lineWidth: 0.5)
//            }
//            .background (
//                Color.clear
//                    .background(.regularMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//            )
        }
        .padding()
        .animation(.easeInOut, value: isInputActive)
    }
    
    private var startSpeakingButton: some View {
        Button {
            if text != "" {
                vm.speak(text)
                
                withAnimation(.easeInOut) {
                    let newRecentPhrase = RecentPhrase(context: context)
                    newRecentPhrase.text = text
                    newRecentPhrase.timeStamp = Date()
                    try? context.save()
                }
            }
        } label: {
            Label("Speak Text", systemImage: "play.circle.fill")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
        }
    }
    
    private var stopSpeakingButton: some View {
        Button {
            vm.synthesizer.stopSpeaking(at: .immediate)
        } label: {
            Label("Speak Text", systemImage: "stop.circle.fill")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
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
}

#Preview {
    TextInputView(text: .constant("Test String"), isInputActive: FocusState<Bool>().projectedValue)
        .environmentObject(ViewModel())
}
