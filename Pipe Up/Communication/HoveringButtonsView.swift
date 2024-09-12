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
    
//    @State private var offset = 0.0
    
    var body: some View {
        Group {
            switch vm.synthesizerState {
            case .speaking:
                HoveringButton(text: "Pause Speech", symbolName: "pause.fill") {
                    vm.pauseSpeaking()
                }
            case .paused:
                VStack {
                    HoveringButton(text: "Cancel Speech", symbolName: "stop.fill") {
                        vm.cancelSpeaking()
                    }
//                    .offset(y: offset)
//                    .onAppear {
//                        withAnimation {
//                            offset = -60
//                        }
//                    }
                    
                    HoveringButton(text: "Continue Speech", symbolName: "play.fill") {
                        vm.continueSpeaking()
                    }
                }
            case .inactive:
                HoveringButton(text: "Show Keyboard", symbolName: "keyboard.fill") {
                    withAnimation {
                        showingTextField = true
                    }
                }
            }
        }
//        .animation(.default, value: vm.synthesizerState)
//        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
    }
}

#Preview {
    HoveringButtonsView(showingTextField: .constant(false))
        .environmentObject(ViewModel())
}
