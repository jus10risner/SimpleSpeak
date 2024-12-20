//
//  HoveringButton.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/5/24.
//

import CoreHaptics
import SwiftUI

struct HoveringButton: View {
    @EnvironmentObject var manager: HapticsManager
//    @State private var engine: CHHapticEngine?
    
    var text: String
    var symbolName: String
    var action: () -> ()
    
    var body: some View {
        Button {
            manager.buttonTapped()
            action()
        } label: {
            Label(text, systemImage: symbolName)
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(Color.white)
                .padding(20)
        }
//        .onAppear(perform: haptics.prepare)
    }
    
//    func prepare() {
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        
//        do {
//            engine = try CHHapticEngine()
//            try engine?.start()
//        } catch {
//            print("Error creating engine. Error: \(error.localizedDescription)")
//        }
//    }
//    
//    func buttonTapped() {
//        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
//        
//        var events = [CHHapticEvent]()
//        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
//        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
//        
//        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
//        events.append(event)
//        
//        do {
//            let pattern = try CHHapticPattern(events: events, parameters: [])
//            let player = try engine?.makePlayer(with: pattern)
//            try player?.start(atTime: 0)
//        } catch {
//            print("Failed to play pattern. Error: \(error.localizedDescription)")
//        }
//    }
}

#Preview {
    HoveringButton(text: "Test", symbolName: "keyboard", action: {})
}
