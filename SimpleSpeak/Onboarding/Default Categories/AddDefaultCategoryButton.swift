//
//  AddDefaultCategoryButton.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/26/25.
//

import SwiftUI

struct AddDefaultCategoryButton: View {
    let action: () -> Void
    let categoryName: String
    let description: String
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                Label("Add \(categoryName) Category", systemImage: "plus.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(Color(.defaultAccent))
            }
            .buttonStyle(.plain)
            
            Spacer().frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(categoryName)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    AddDefaultCategoryButton(action: {}, categoryName: "Saved", description: "An empty category for phrases you use frequently.")
}
