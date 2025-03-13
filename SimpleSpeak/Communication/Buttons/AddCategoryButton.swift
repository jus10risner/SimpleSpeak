//
//  AddCategoryButton.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/28/25.
//

import SwiftUI

struct AddCategoryButton: View {
    @EnvironmentObject var vm: ViewModel
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Label("Add Category", systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.headline)
                .padding()
                .frame(height: 50)
                .overlay {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(Color.secondary)
                        .opacity(0.5)
                }
        }
    }
}

#Preview {
    AddCategoryButton(action: {})
        .environmentObject(ViewModel())
}
