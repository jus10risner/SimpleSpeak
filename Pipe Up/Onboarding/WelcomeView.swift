//
//  WelcomeView.swift
//  Pipe Up
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("showingWelcomeView") var showingWelcomeView: Bool = true
    
    var body: some View {
        VStack(alignment: .center) {
           Spacer()
            
            VStack {
//                Image("Primary Icon")
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .padding(.bottom, 10)
                
                Text("Welcome to")
                
                Text("SimpleSpeak")
            }
            .font(.largeTitle.bold())

            VStack(alignment: .leading) {
                InformationItemView(title: "Speak", subtitle: "Make yourself heard, using your preferred voice.", imageName: "person.wave.2.fill")
                
                InformationItemView(title: "Customize", subtitle: "Add your own phrases, and speak them with a tap.", imageName: "star.fill")
                
                InformationItemView(title: "Call", subtitle: "Talk to friends and family on the phone or FaceTime.", imageName: "phone.fill")
            }
            
            Spacer()
            
            Button {
                showingWelcomeView = false
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
