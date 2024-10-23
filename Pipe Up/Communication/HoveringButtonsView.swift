//
//  HoveringButtonsView.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/9/24.
//

import SwiftUI

struct HoveringButtonsView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var showingTextField: Bool
    
    var body: some View {
        ZStack {
            Button(role: .destructive) {
                vm.cancelSpeaking()
            } label: {
                Label("Cancel Speech", systemImage: "stop.circle.fill")
                    .labelStyle(.iconOnly)
                    .symbolRenderingMode(.multicolor)
                    .font(.title)
            }
            .offset(x: vm.synthesizerState == .paused ? -60 : 0)
            .transition(.move(edge: .trailing))
            
            ZStack {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color(.defaultAccent))
//                    .shadow(radius: 5)
                
                Group {
                    switch vm.synthesizerState {
                    case .speaking:
                        HoveringButton(text: "Pause Speech", symbolName: "pause.fill") {
                            vm.pauseSpeaking()
                        }
                    case .paused:
                        HoveringButton(text: "Continue Speech", symbolName: "play.fill") {
                            vm.continueSpeaking()
                        }
                    case .inactive:
                        HoveringButton(text: "Show Keyboard", symbolName: "keyboard.fill") {
                            withAnimation {
                                showingTextField = true
                            }
                        }
                    }
                }
                .zIndex(1) // This is necessary for the removal animation (button disappears instantly otherwise)
                .transition(.offset(y: 50).combined(with: .move(edge: .bottom)))
            }
            .mask(Circle())
            .shadow(radius: 5)
        }
        .padding(.bottom, 10)
        .animation(.bouncy(extraBounce: -0.1), value: vm.synthesizerState)
    }
}

#Preview {
    HoveringButtonsView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}
