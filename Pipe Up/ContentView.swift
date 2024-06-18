//
//  ContentView.swift
//  QuickSpeak
//
//  Created by Justin Risner on 5/8/23.
//

import AVFoundation
//import CallKit
import SwiftUI

struct ContentView: View {
    let synthesizer = AVSpeechSynthesizer()
    @State private var useDuringCalls = true
    @State private var text = ""
    
    @FocusState var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.indigo
                    .edgesIgnoringSafeArea(.all)
                
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
//                        
                    Button("Done") { isInputActive = false }
                }
            }
        }
        .preferredColorScheme(.light)
//        .tint(.white)
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.mixToTelephonyUplink = useDuringCalls ? true : false
        synthesizer.speak(utterance)
    }
    
//    var isOnPhoneCall: Bool {
//        return CXCallObserver().calls.contains { $0.hasEnded == false }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
