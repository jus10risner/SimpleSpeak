//
//  EditCategoryView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct EditCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftCategory: DraftCategory
    
    let selectedCategory: PhraseCategory
    
    init(selectedCategory: PhraseCategory) {
        self.selectedCategory = selectedCategory
        
        _draftCategory = StateObject(wrappedValue: DraftCategory(phraseCategory: selectedCategory))
    }
    
    var body: some View {
        NavigationStack {
            DraftCategoryView(draftCategory: draftCategory, isEditing: true, selectedCategory: selectedCategory)
                .navigationTitle("Edit Category")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EditCategoryView(selectedCategory: PhraseCategory(context: DataController.preview.container.viewContext))
}
