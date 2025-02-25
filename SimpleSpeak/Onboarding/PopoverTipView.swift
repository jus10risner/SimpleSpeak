//
//  PopoverTipView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/19/25.
//

import SwiftUI

struct PopoverTipView: View {
    let symbolName: String
    let title: String?
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .font(.title)
                .foregroundStyle(Color(.defaultAccent))
                .padding(.trailing)
            
            VStack(alignment: .leading, spacing: 5) {
                if let title {
                    Text(title)
                        .font(.headline)
                }
                
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding()
        .frame(width: 300)
        .presentationCompactAdaptation(.popover)
        .presentationBackground(.regularMaterial)
    }
}

#Preview {
    PopoverTipView(symbolName: "hand.tap.fill", title: "Tip", text: "Tap me!")
}
