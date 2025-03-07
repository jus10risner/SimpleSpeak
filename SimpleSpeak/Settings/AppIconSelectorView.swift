//
//  AppIconSelectorView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 3/7/25.
//

import SwiftUI

struct AppIconSelectorView: View {
    @State private var selectedIcon: AppIcons = .appIcon
    
    var body: some View {
        List {
            Section {
                ForEach(AppIcons.allCases, id: \.rawValue) { icon in
                    HStack {
                        Image(decorative: icon.previewImage)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.secondary, radius: 0.5)
                        
                        Text(icon.rawValue)
                        
                        Spacer()
                        
                        if selectedIcon == icon {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(.defaultAccent))
                        }
                    }
                    .onTapGesture {
                        selectedIcon = icon
                        UIApplication.shared.setAlternateIconName(icon.assignedValue)
                    }
                }
            } header: {
                Text("Select an app icon")
            } footer: {
                if #available(iOS 18.0, *) {
                    Text("**Note:** If your system icons are set to the *Dark* theme, only the **Monochrome** option will have an effect.")
                }
            }
            .textCase(nil)
        }
        .navigationTitle("App Icon")
        .onAppear {
            if let alternateAppIcon = UIApplication.shared.alternateIconName, let appIcon = AppIcons.allCases.first(where: { $0.rawValue == alternateAppIcon }) {
                selectedIcon = appIcon
            } else {
                selectedIcon = .appIcon
            }
        }
    }
}

#Preview {
    AppIconSelectorView()
}

enum AppIcons: String, CaseIterable {
    case appIcon = "Primary", dark = "Dark", light = "Light", monochrome = "Monochrome"
    
    // Determines whether to use the default icon or an alternate version
    var assignedValue: String? {
        if self == .appIcon {
            return nil
        } else {
            return rawValue
        }
    }
    
    // Images to show in the selection list
    var previewImage: String {
        switch self {
        case .appIcon:
            return "Primary"
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        case .monochrome:
            return "Monochrome"
        }
    }
}
