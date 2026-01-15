//
//  SpokenTextLabel.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 1/14/25.
//

import Foundation
import SwiftUI

struct SpokenTextLabel: UIViewRepresentable {
    var text: NSAttributedString?
    var font: UIFont
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // Forces label to wrap, when extending beyond horizontal bounds
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        guard let text = text else {
            uiView.attributedText = nil
            return
        }
        let mutable = NSMutableAttributedString(attributedString: text)
        mutable.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.length))
        uiView.attributedText = mutable
    }
}
