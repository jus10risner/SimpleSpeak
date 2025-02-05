//
//  HoveringButton.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/5/24.
//

import CoreHaptics
import SwiftUI

struct HoveringButton: View {
//    @EnvironmentObject var manager: HapticsManager
    
    var text: String
    var symbolName: String
    var action: () -> ()
    
    var body: some View {
        Button {
//            manager.buttonTapped()
            action()
        } label: {
            Label(text, systemImage: symbolName)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(Color.white)
                .padding(20)
        }
    }
}

#Preview {
    HoveringButton(text: "Test", symbolName: "keyboard", action: {})
}
