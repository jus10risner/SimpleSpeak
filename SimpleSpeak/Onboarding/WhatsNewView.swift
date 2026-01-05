//
//  WhatsNewView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 1/5/26.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 50) {
                        Text("What's New in SimpleSpeak")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            InformationItemView(title: "Text Size Options", description: "Adjust phrase text size to fit your needs.", imageName: "textformat.size")
                            
                            InformationItemView(title: "Phrase Colors", description: "Add colors to individual phrases, for easy identification.", imageName: "paintpalette")
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Adds padding to the top of the scrollview, so the headline isn't in the toolbar area
                    Text(" ")
                        .opacity(0)
                }
            }
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    WhatsNewView()
}
