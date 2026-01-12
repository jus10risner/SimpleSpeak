//
//  WelcomeView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var onboardingSheet: ActiveOnboardingSheet?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 50) {
                        VStack(spacing: 15) {
                            Image("Primary Icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .frame(maxWidth: .infinity)
                                .environment(\.colorScheme, {
                                    if #available(iOS 18, *) {
                                        return colorScheme
                                    } else {
                                        // iOS 17: force light mode only, since icons don't adapt for light/dark
                                        return .light
                                    }
                                }())
                            
                            Text("Welcome to SimpleSpeak")
                                .font(.title.bold())
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            InformationItemView(title: "Communicate", description: "Make yourself heard, using your preferred voice.", imageName: "person.wave.2.fill")
                            
                            InformationItemView(title: "Customize", description: "Add and categorize phrases, then speak them with a tap.", imageName: "star.fill")
                            
                            InformationItemView(title: "Connect", description: "Use during phone or FaceTime calls to talk to friends and family.", imageName: "phone.fill")
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                NavigationLink {
                    CategoriesExplanationView(onboardingSheet: $onboardingSheet)
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
            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Adds padding to the top of the scrollview, so the icon isn't in the toolbar area
                    Text(" ")
                        .opacity(0)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
}

#Preview {
    WelcomeView(onboardingSheet: .constant(nil))
}
