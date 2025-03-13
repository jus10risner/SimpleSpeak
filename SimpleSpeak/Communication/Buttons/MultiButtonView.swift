//
//  MultiButtonView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/9/24.
//

import SwiftUI

struct MultiButtonView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var showingTextField: Bool
    
    var body: some View {
        ZStack {
            if vm.synthesizerState == .paused { // Required, because VoiceOver ignores .accessibilityHidden() inside ZStacks
                Button(role: .destructive) {
                    Task { await vm.cancelSpeaking() }
                } label: {
                    Label("Cancel Speech", systemImage: "stop.circle.fill")
                        .labelStyle(.iconOnly)
                        .symbolRenderingMode(.multicolor)
                        .font(.largeTitle)
                }
                .offset(x: vm.synthesizerState == .paused ? -60 : 0)
                .accessibilityHidden(vm.synthesizerState != .paused)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            ZStack {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color(.defaultAccent))
                
                Group {
                    switch vm.synthesizerState {
                    case .speaking:
                        MultiButton(text: "Pause Speech", symbolName: "pause.fill") {
                            Task { await vm.pauseSpeaking() }
                        }
                    case .paused:
                        MultiButton(text: "Continue Speech", symbolName: "play.fill") {
                            Task { await vm.continueSpeaking() }
                        }
                    case .inactive:
                        MultiButton(text: "Show Keyboard", symbolName: "keyboard.fill") {
                            withAnimation {
                                vm.phraseIsRepeatable = false
                                showingTextField = true
                            }
                        }
                    }
                }
                .zIndex(1) // This is necessary for the removal animation (button disappears instantly otherwise)
                .transition(.offset(y: 50).combined(with: .move(edge: .bottom)))
            }
            .mask(Circle())
        }
        .animation(.bouncy(extraBounce: -0.1), value: vm.synthesizerState)
    }
}

#Preview {
    MultiButtonView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}
