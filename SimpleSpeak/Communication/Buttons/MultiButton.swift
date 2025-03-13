//
//  MultiButton.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/5/24.
//

import SwiftUI

struct MultiButton: View {
    var text: String
    var symbolName: String
    var action: () -> ()
    
    var body: some View {
        Button {
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
    MultiButton(text: "Test", symbolName: "keyboard", action: {})
}
