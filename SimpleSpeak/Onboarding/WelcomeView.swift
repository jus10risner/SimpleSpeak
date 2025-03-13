//
//  WelcomeView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Spacer()
                
                VStack {
                    Image("Primary")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .padding(.bottom, 10)
                    
                    Text("Welcome to SimpleSpeak")
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                }
                .font(.title.bold())
                
                VStack(alignment: .leading) {
                    InformationItemView(title: "Communicate", subtitle: "Make yourself heard, using your preferred voice.", imageName: "person.wave.2.fill")
                    
                    InformationItemView(title: "Customize", subtitle: "Add and categorize phrases, then speak them with a tap.", imageName: "star.fill")
                    
                    InformationItemView(title: "Connect", subtitle: "Use during phone or FaceTime calls to talk to friends and family.", imageName: "phone.fill")
                }
                
                Spacer()
                
                NavigationLink {
                    CategoriesExplanationView()
                } label: {
                    buttonLabel
                }
                .buttonStyle(.plain)
            }
            .interactiveDismissDisabled()
            .padding(.horizontal)
        }
    }
    
    private var buttonLabel: some View {
        Text("Next")
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
