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
    
    @State private var categoryButtonExpanded = false
    @State private var phraseButtonExpanded = false
    
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
                    .scaleEffect(phraseButtonExpanded ? 1 : 0.9)
                    .accessibilityHidden(true)
            
                Text("In SimpleSpeak, *phrases* are words or sentences you can speak with a tap.")
            }
            
            Spacer().frame(height: 75)
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(categoryButtonExpanded ? Color(.defaultAccent) : Color.secondary)
                    
                    if categoryButtonExpanded {
                        Text("Saved")
                    }
                }
                .font(.headline)
                .foregroundStyle(categoryButtonExpanded ? Color.primary : Color.secondary)
                .padding()
                .frame(height: 50)
                .overlay {
                    RoundedRectangle(cornerRadius: vm.cornerRadius)
                        .stroke(categoryButtonExpanded ? Color.primary : Color.secondary, lineWidth: 2)
                }
                .mask(RoundedRectangle(cornerRadius: vm.cornerRadius))
                .drawingGroup()
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
        .multilineTextAlignment(.center)
        .frame(width: 300)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    phraseButtonExpanded = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    categoryButtonExpanded = true
                }
            }
        }
    }
}

#Preview {
    CategoriesExplanationView()
        .environmentObject(ViewModel())
}
