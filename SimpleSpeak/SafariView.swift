//
//  SafariView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 6/21/24.
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
                
        // Prevents the navigation bar from becoming too slim, when presented in a sheet
        safariVC.modalPresentationStyle = .pageSheet
        
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}
