//
//  AddCategoryView.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftCategory: DraftCategory
    
    init() {
        _draftCategory = StateObject(wrappedValue: DraftCategory())
    }
    
    var body: some View {
        NavigationStack {
            DraftCategoryView(draftCategory: draftCategory, isEditing: false, selectedCategory: nil)
                .navigationTitle("Add Category")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddCategoryView()
}
