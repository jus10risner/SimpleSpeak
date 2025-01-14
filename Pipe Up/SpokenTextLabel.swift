//
//  SpokenTextLabel.swift
//  Pipe Up
//
//  Created by Justin Risner on 1/14/25.
//

import Foundation
import SwiftUI

struct SpokenTextLabel: UIViewRepresentable {
    var text : NSAttributedString?
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // Forces label to wrap, when extending beyond horizontal bounds
        label.minimumScaleFactor = 0.9
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = text
    }
}
