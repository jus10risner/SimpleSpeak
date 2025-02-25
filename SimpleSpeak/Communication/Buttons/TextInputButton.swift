//
//  TextInputButton.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/5/24.
//

import SwiftUI

struct TextInputButton: View {
    var text: String
    var symbolName: String
    var color: Color?
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Label(text, systemImage: symbolName)
                .labelStyle(.iconOnly)
                .font(.title)
                .foregroundStyle(color ?? Color(.defaultAccent))
                .symbolRenderingMode(color == nil || color == .red ? .multicolor : .hierarchical)
                .fixedSize()
        }
    }
}

#Preview {
    TextInputButton(text: "Test", symbolName: "keyboard", action: {})
}
