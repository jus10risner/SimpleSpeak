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
                    
                    Text("""
                        Welcome to 
                        SimpleSpeak
                        """)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading) {
                    InformationItemView(title: "Communicate", subtitle: "Make yourself heard, using your preferred voice.", imageName: "person.wave.2.fill")
                    
                    InformationItemView(title: "Customize", subtitle: "Add and categorize phrases, then speak them with a tap.", imageName: "star.fill")
                    
                    InformationItemView(title: "Connect", subtitle: "Use during phone or FaceTime calls to talk to friends and family.", imageName: "phone.fill")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                NavigationLink {
                    CategoriesExplanationView()
                } label: {
                    Text("Next")
                        .font(.headline)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 350)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
            }
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    WelcomeView()
}
