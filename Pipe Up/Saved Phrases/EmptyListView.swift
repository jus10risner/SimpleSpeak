//
//  EmptyListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/15/24.
//

import SwiftUI

struct EmptyListView: View {
    let category: PhraseCategory?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            
            VStack(spacing: 10) {
                Image(systemName: category?.symbolName ?? "clock.arrow.circlepath")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 5) {
                    Text(category == nil ? "No Recents" : "No Phrases")
                        .font(.title2.bold())
                    
                    Text(category == nil ? "" : "Tap the plus button to add a phrase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    EmptyListView(category: nil)
}
