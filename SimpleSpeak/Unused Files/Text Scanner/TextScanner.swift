//
//  TextScanner.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 8/1/24.
//

import SwiftUI
import UIKit
import VisionKit

// Source: https://github.com/appcoda/LiveTextDemo/blob/main/LiveTextDemo/DataScanner.swift
struct TextScanner: UIViewControllerRepresentable {
    
    @Binding var startScanning: Bool
    @Binding var scanText: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
                            recognizedDataTypes: [.text()],
                            qualityLevel: .balanced,
                            isHighlightingEnabled: true
                        )
        
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
        if startScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: TextScanner
        
        init(_ parent: TextScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scanText = text.transcript
            default: break
            }
        }
        
    }
}
