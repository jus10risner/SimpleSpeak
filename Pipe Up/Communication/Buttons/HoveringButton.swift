//
//  HoveringButton.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/5/24.
//

import SwiftUI

struct HoveringButton: View {
    var text: String
    var symbolName: String
    var action: () -> ()
    
    var body: some View {
        Circle()
            .frame(width: 50, height: 50)
            .foregroundStyle(Color(.defaultAccent))
            .shadow(radius: 5)
            .overlay {
                Button(action: action, label: {
                    Label(text, systemImage: symbolName)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(Color.white)
                        .padding()
                })
            }
    }
}

#Preview {
    HoveringButton(text: "Test", symbolName: "keyboard", action: {})
}
