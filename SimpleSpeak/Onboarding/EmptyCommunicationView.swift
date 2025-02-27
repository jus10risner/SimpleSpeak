//
//  EmptyCommunicationView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/18/25.
//

import SwiftUI

struct EmptyCommunicationView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var vm: ViewModel
    
    @Binding var showingAddCategory: Bool
    @Binding var showingDefaultCategoriesSelector: Bool
    @State private var showingCategoryExplanation = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Tap")
                
                Button {
                    showingAddCategory = true
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
                
                Text("to add a category")
            }
            .font(.title2.bold())
            .accessibilityElement()
            .accessibilityLabel("Tap Add Category to add your first category.")
            
            VStack {
                Text("Not sure where to start?")
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Use Pre-made Categories") { showingDefaultCategoriesSelector = true }
            }
            .font(.subheadline)
        }
        .padding()
    }
}

#Preview {
    EmptyCommunicationView(showingAddCategory: .constant(false), showingDefaultCategoriesSelector: .constant(false))
        .environmentObject(ViewModel())
}
