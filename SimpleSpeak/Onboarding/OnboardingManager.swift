//
//  OnboardingManager.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/24/25.
//

import SwiftUI

@MainActor
class OnboardingManager: ObservableObject {
    @AppStorage("currentStep") var currentStep: OnboardingStep = .welcome
    @AppStorage("isComplete") var isComplete: Bool = false
    
    @AppStorage("isShowingWelcomeView") var isShowingWelcomeView: Bool = true
    @AppStorage("isShowingMultiButtonTip") var isShowingMultiButtonTip: Bool = false
    @AppStorage("isShowingManageCategoryTip") var isShowingManageCategoryTip: Bool = false
    
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
