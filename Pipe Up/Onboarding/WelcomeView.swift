//
//  WelcomeView.swift
//  Pipe Up
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("Welcome to Pipe Up")
                .font(.largeTitle.bold())
            
//            Spacer()
            
            speakInfo
            
            savePhrase
            
            Spacer()

        }
        .padding(.horizontal)
    }
    
    private var speakInfo: some View {
        HStack(alignment: .center) {
            Image(systemName: "keyboard")
                .font(.largeTitle)
                .foregroundColor(Color(.defaultAccent))
                .padding()
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text("Speak")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

                Text("Type phrases to have the app speak them out loud.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
    
    private var savePhrase: some View {
        HStack(alignment: .center) {
            Image(systemName: "bookmark")
                .font(.largeTitle)
                .foregroundColor(Color(.defaultAccent))
                .padding()
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text("Save Phrases")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

                Text("Add your own commonly-used phrases, and speak them with a tap.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

#Preview {
    WelcomeView()
}
