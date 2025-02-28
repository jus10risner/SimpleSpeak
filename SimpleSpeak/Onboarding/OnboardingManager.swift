//
//  OnboardingManager.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/24/25.
//

import SwiftUI

class OnboardingManager: ObservableObject {
    @AppStorage("currentStep") var currentStep: OnboardingStep = .welcome
    @AppStorage("isComplete") var isComplete: Bool = false
    
    @AppStorage("isShowingWelcomeView") var isShowingWelcomeView: Bool = true
    @AppStorage("isShowingMultiButtonTip") var isShowingMultiButtonTip: Bool = false
    @AppStorage("isShowingManageCategoryTip") var isShowingManageCategoryTip: Bool = false
    
//    @Published var currentStep: OnboardingStep = .welcome
//    @Published var isComplete: Bool = false
//    @Published var isShowingWelcomeView: Bool = true
//    @Published var isShowingMultiButtonTip: Bool = false
//    @Published var isShowingManageCategoryTip: Bool = false
    
    func showWelcome() {
        if isComplete == false && currentStep == .welcome {
            self.isShowingWelcomeView = true
        }
    }

    enum OnboardingStep: Int {
        case welcome
        case multiButton
        case manageCategory
        case complete
    }
}
