//
//  AdaptiveLabelStyle.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 12/18/25.
//

import SwiftUI

struct AdaptiveLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26, *) {
            configuration.icon
        } else {
            configuration.title
        }
    }
}

extension LabelStyle where Self == AdaptiveLabelStyle {
    static var adaptive: AdaptiveLabelStyle { AdaptiveLabelStyle() }
}
