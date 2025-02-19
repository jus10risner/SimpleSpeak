//
//  MultiButtonView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/9/24.
//

import SwiftUI

struct MultiButtonView: View {
//    @EnvironmentObject var manager: HapticsManager
    @EnvironmentObject var vm: ViewModel
    @Binding var showingTextField: Bool
    
    var body: some View {
        ZStack {
            Button(role: .destructive) {
//                manager.buttonTapped()
                Task { await vm.cancelSpeaking() }
            } label: {
                Label("Cancel Speech", systemImage: "stop.circle.fill")
                    .labelStyle(.iconOnly)
                    .symbolRenderingMode(.multicolor)
                    .font(.largeTitle)
//                    .shadow(radius: 5)
            }
            .offset(x: vm.synthesizerState == .paused ? -60 : 0)
            .accessibilityHidden(vm.synthesizerState == .paused ? false : true)
            .transition(.move(edge: .trailing))
            
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
//            .shadow(radius: 5)
        }
//        .padding(.bottom, bottomPadding)
        .animation(.bouncy(extraBounce: -0.1), value: vm.synthesizerState)
    }
    
//    // Check for safe area padding at the bottom, to determine if the device has a Home Button
//    private var hasHomeButton: Bool {
//        let scenes = UIApplication.shared.connectedScenes
//        let windowScene = scenes.first as? UIWindowScene
//        guard let window = windowScene?.windows.first else { return false }
//                    
//        return window.safeAreaInsets.bottom == 0
//    }
//    
//    // Determine bottom padding, based on whether the device is an iPad; uses presence of Home Button, if not an iPad
//    private var bottomPadding: CGFloat {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return 20
//        } else {
//            return hasHomeButton ? 10 : 0
//        }
//    }
}

#Preview {
    MultiButtonView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}
