//
//  AppearanceController.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/18/24.
//

import SwiftUI

class AppearanceController {
    @ObservedObject var vm = ViewModel()
    static let shared = AppearanceController()
    
    var appearance: UIUserInterfaceStyle {
        switch vm.appAppearance {
        case .automatic:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    func setAppearance() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return }
        window.overrideUserInterfaceStyle = appearance
    }
}

enum AppearanceOptions: String, CaseIterable {
    case automatic, light, dark
}
