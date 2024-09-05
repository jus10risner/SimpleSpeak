//
//  TextInputButton.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/5/24.
//

import SwiftUI

struct TextInputButton: View {
    var text: String
    var symbolName: String
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Label(text, systemImage: symbolName)
                .labelStyle(.iconOnly)
                .font(.title)
                .symbolRenderingMode(.hierarchical)
        }
    }
}

#Preview {
    TextInputButton(text: "Test", symbolName: "keyboard", action: {})
}
