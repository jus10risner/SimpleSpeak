//
//  CommunicationView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/19/24.
//

import AVFoundation
import SwiftUI

struct CommunicationView: View {
    let synthesizer = AVSpeechSynthesizer()
    @State private var useDuringCalls = true
    @State private var text = ""
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
//                Color.cyan
//                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    TextField("What would you like to say?", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.send)
                        .focused($isInputActive)
                    
//                    Button("Speak Text") {
//                        speak(text)
//                    }
                }
                .padding()
            }
            .onSubmit {
                speak(text)
                text = ""
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        useDuringCalls.toggle()
                    } label: {
                        Image(systemName: useDuringCalls ? "phone.and.waveform.fill" : "phone.and.waveform")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") { isInputActive = false }
                }
            }
        }
    }
    
    @available (iOS 17, *)
    private var personalVoices: [AVSpeechSynthesisVoice] {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter({$0.voiceTraits == .isPersonalVoice})
        
        return voices
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        if #available(iOS 17, *) {
            utterance.voice = personalVoices.first
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        synthesizer.mixToTelephonyUplink = useDuringCalls ? true : false
        synthesizer.speak(utterance)
    }
}

#Preview {
    CommunicationView()
}
