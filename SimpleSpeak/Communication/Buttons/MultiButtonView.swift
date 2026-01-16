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
            if vm.synthesizerState == .paused { // Required (VoiceOver ignores .accessibilityHidden() inside ZStacks)
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
            
            Button {
                switch vm.synthesizerState {
                case .speaking:
                    Task { await vm.pauseSpeaking() }

                case .paused:
                    Task { await vm.continueSpeaking() }

                case .inactive:
                    withAnimation {
                        vm.phraseIsRepeatable = false
                        showingTextField = true
                    }
                }
            } label: {
                Label(buttonTitle, systemImage: symbolName)
                    .labelStyle(.iconOnly)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 50, height: 50)
                    .font(.title3)
                    .foregroundStyle(Color.white)
                    .padding(20)
            }
            .background {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color(.accent))
            }
        }
        .animation(.bouncy(extraBounce: -0.1), value: vm.synthesizerState)
    }
    
    private var buttonTitle: String {
        switch vm.synthesizerState {
        case .speaking: return "Pause Speech"
        case .paused:   return "Continue Speech"
        case .inactive: return "Show Keyboard"
        }
    }
    
    private var symbolName: String {
        switch vm.synthesizerState {
        case .speaking: return "pause.fill"
        case .paused:   return "play.fill"
        case .inactive: return "keyboard.fill"
        }
    }
}

#Preview {
    MultiButtonView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}
