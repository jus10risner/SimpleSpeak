//
//  RecentsCardView.swift
//  Pipe Up
//
//  Created by Justin Risner on 11/12/24.
//

import SwiftUI

struct RecentsCardView: View {
    @EnvironmentObject var vm: ViewModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SavedPhrase.displayOrder, ascending: false)], predicate: NSPredicate(format: "category == %@", NSNull()), animation: .easeInOut) var recentPhrases: FetchedResults<SavedPhrase>
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 5)]
    
    @Namespace var animation
    @State private var animationEnabled = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(recentPhrases, id: \.id) { phrase in
                    Button {
                        if vm.synthesizerState != .inactive {
                            vm.cancelSpeaking()
                        }
                        
                        vm.speak(phrase.text)
                    } label: {
                        ZStack {
                            Text(phrase.text)
                                .font(.headline)
                                .minimumScaleFactor(0.9)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(height: 100)
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: vm.cornerRadius))
                        .matchedGeometryEffect(id: phrase.id, in: animation)
                        .drawingGroup()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding([.horizontal, .bottom])
            .animation(animationEnabled ? .easeInOut : nil, value: recentPhrases.count)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Briefly prevents animation when view appears; only animates updates to Recents while the tab is active
                animationEnabled = true
            }
        }
        .onDisappear {
            // Prevents unexpected animation when returning to the Recents tab; without this, FetchRequest animates updates that occurred while the tab was not active
            animationEnabled = false
        }
    }
}

#Preview {
    RecentsCardView()
}
