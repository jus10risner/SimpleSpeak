//
//  MailComposeViewController.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 2/19/25.
//

import MessageUI
import SwiftUI

class MailComposeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    static let shared = MailComposeViewController()
    
    var canSendEmail: Bool {
        if MFMailComposeViewController.canSendMail() {
            return true
        } else {
            return false
        }
    }

    func sendEmail() {
        let appInfo = AppInfo()
        let appVersion = appInfo.version
        let buildNumber = appInfo.build
        let operatingSystem = UIDevice.current.systemVersion
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["feedback@justinrisner.com"])
        mail.setMessageBody("\n\n\nSimpleSpeak Version: \(appVersion) (\(buildNumber))\niOS Version: \(operatingSystem)", isHTML: false)
        
        // Finds the topmost view controller and presents from there, to avoid "...which was already presenting" error in console
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return }
        guard var topVC = window.rootViewController else { return }
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        topVC.present(mail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
