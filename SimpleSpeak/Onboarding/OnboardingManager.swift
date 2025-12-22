//
//  OnboardingManager.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/24/25.
//

import SwiftUI

@MainActor
class OnboardingManager: ObservableObject {
    // Used to determine whether the user has launched the app since the most recent update was released
    @AppStorage("savedAppVersion") var savedAppVersion: String = ""
    
    @AppStorage("isShowingWelcomeView") var isShowingWelcomeView: Bool = true
    @AppStorage("isShowingWhatsNewView") var isShowingWhatsNewView: Bool = false
}
