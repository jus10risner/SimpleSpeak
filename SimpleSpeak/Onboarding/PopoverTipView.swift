//
//  PopoverTipView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/19/25.
//

import SwiftUI

struct PopoverTipView: View {
    let symbolName: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .font(.title)
                .foregroundStyle(Color.secondary)
                .padding(.trailing)
            
            Text(text)
        }
        .padding()
        .frame(width: 300)
        .presentationCompactAdaptation(.popover)
    }
}

#Preview {
    PopoverTipView(symbolName: "hand.tap.fill", text: "Tap me!")
}
