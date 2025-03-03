//
//  CategoriesExplanationView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/28/25.
//

import SwiftUI

struct CategoriesExplanationView: View {
    @EnvironmentObject var onboarding: OnboardingManager
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Hello")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(width: 150, height: 100)
                    .background {
                        RoundedRectangle(cornerRadius: vm.cornerRadius)
                            .fill(Color(.tertiarySystemGroupedBackground).shadow(.drop(radius: 1)))
                    }
                    .accessibilityHidden(true)
            
                Text("In SimpleSpeak, *phrases* are words or sentences you can speak with a tap.")
            }
            
            Spacer().frame(height: 75)
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Color(.defaultAccent))
                    
                    Text("Saved")
                }
                .font(.headline)
                .padding()
                .frame(height: 50)
                .overlay {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .stroke(lineWidth: 2)
                }
                .accessibilityHidden(true)
                
                Text("You can group these phrases into *categories*, making it easy to find the ones you need quickly.")
            }
            
            Spacer()
            
            Button {
                onboarding.isShowingWelcomeView = false
            } label: {
                Text("Get Started")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background {
                        RoundedRectangle(cornerRadius: vm.cornerRadius, style: .continuous)
                            .fill(Color(.defaultAccent))
                    }
                    .padding(.bottom)
            }
        }
//        .font(.title3)
        .multilineTextAlignment(.center)
//        .padding()
//        .padding(30)
        .frame(width: 300)
    }
}

#Preview {
    CategoriesExplanationView()
        .environmentObject(ViewModel())
}
