//
//  WelcomeView.swift
//  Pipe Up
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(alignment: .center) {
           Spacer()
            
            VStack {
//                Image("Primary Icon")
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .padding(.bottom, 10)
                
                Text("Welcome to")
                
                Text("The App")
            }
            .font(.largeTitle.bold())

            VStack(alignment: .leading) {
                InformationItemView(title: "Speak", subtitle: "Type phrases to have the app speak them out loud.", imageName: "person.wave.2.fill")
                
                InformationItemView(title: "Save", subtitle: "Add your own commonly-used phrases, and speak them with a tap.", imageName: "bookmark.fill")
                
                InformationItemView(title: "Call", subtitle: "Use the app to speak phrases over the phone and in FaceTime calls.", imageName: "phone.fill")
            }
            
            Spacer()
            
            Button {
                // Dismiss button
            } label: {
                buttonLabel
            }
            .buttonStyle(.plain)
        }
        .interactiveDismissDisabled()
        .padding(.horizontal)
    }
    
    private var buttonLabel: some View {
        Text("Continue")
        .foregroundColor(.white)
        .font(.headline)
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(.defaultAccent))
        }
        .padding(.bottom)
    }
}

#Preview {
    WelcomeView()
}
