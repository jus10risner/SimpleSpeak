//
//  TextScannerView.swift
//  Pipe Up
//
//  Created by Justin Risner on 8/1/24.
//

import SwiftUI
import VisionKit

struct TextScannerView: View {
    @State private var startScanning = false
       @State private var scanText = ""
       
       var body: some View {
           
           VStack(spacing: 0) {
               TextScanner(startScanning: $startScanning, scanText: $scanText)
                   .frame(height: 400)
               
               Text(scanText)
                   .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                   .background(in: Rectangle())
                   .backgroundStyle(Color(uiColor: .systemGray6))
                   
           }
           .task {
               if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                   startScanning.toggle()
               }
           }

       }
}

#Preview {
    TextScannerView()
}
