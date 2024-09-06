//
//  EmptyListView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/15/24.
//

import SwiftUI

struct EmptyListView: View {
    let systemImage: String
    let headline: String
    let subheadline: String?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 5) {
                    Text(headline)
                        .font(.title2.bold())
                    
                    if let subheadline {
                        Text(subheadline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    EmptyListView(systemImage: "bookmark", headline: "No Phrases", subheadline: "Tap plus to add a phrase.")
}
