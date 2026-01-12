//
//  AppIconSelectorView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 3/7/25.
//

import SwiftUI

struct AppIconSelectorView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("appIcon") var appIcon: AppIcon?
    
    var body: some View {
        List {
            Picker("Icons", selection: $appIcon) {
                iconLabel(title: "SimpleSpeak Teal", iconName: "Primary Icon")
                    .tag(nil as AppIcon?)
                
                ForEach(AppIcon.allCases, id: \.self) { icon in
                    iconLabel(title: "\(icon.rawValue)", iconName: "\(icon.rawValue) Icon")
                        .tag(icon) // This connects the row to the selection binding
                }
            }
        }
        .pickerStyle(.inline)
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: appIcon) {
            UIApplication.shared.setAlternateIconName(appIcon?.rawValue)
        }
    }
    
    private func iconLabel(title: String, iconName: String) -> some View {
        Label {
            Text(title)
                .padding(.leading, 5)
        } icon: {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary, lineWidth: 0.2)
                )
                .environment(\.colorScheme,
                    {
                        if #available(iOS 18, *) {
                            return colorScheme
                        } else {
                            // iOS 17: force light mode only
                            return .light
                        }
                    }()
                )
        }
        .padding(8)
    }
}

#Preview {
    AppIconSelectorView()
}

enum AppIcon: String, CaseIterable {
    case monochrome = "Monochrome", classicTeal = "Classic Teal", classicMonochrome = "Classic Monochrome"
    
    // Images to show in the selection list
    var previewImage: String {
        switch self {
        case .monochrome:
            return "Monochrome"
        case .classicTeal:
            return "Classic Teal"
        case .classicMonochrome:
            return "Classic Monochrome"
        }
    }
}
