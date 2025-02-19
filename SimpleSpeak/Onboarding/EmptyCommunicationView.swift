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
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Tap")
                
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(Color(.defaultAccent))
                        .frame(width: 50, height: 50)
                        .overlay {
                            RoundedRectangle(cornerRadius: vm.cornerRadius)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundStyle(Color.secondary)
                        }
                }
                
                Text("to add a category")
            }
            .font(.title2.bold())
            .accessibilityElement()
            .accessibilityLabel("Tap the Add Category button to add a category.")
                
            Text("Use categories to group phrases by theme, for quick communication.")
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            
            VStack {
                Text("Not sure where to start?")
                    .foregroundStyle(Color.secondary)
                
                Button("Add Favorites category") {
                    addFavoritesCategory()
                }
            }
            .padding(.top, 40)
        }
        .frame(width: 300)
    }
    
    func addFavoritesCategory() {
        let newCategory = PhraseCategory(context: context)
        newCategory.id = UUID()
        newCategory.title = "Favorites"
        newCategory.symbolName = "star.fill"
        newCategory.displayOrder = 0
    
        try? context.save()
    }
}

#Preview {
    EmptyCommunicationView(showingAddCategory: .constant(false))
        .environmentObject(ViewModel())
}
