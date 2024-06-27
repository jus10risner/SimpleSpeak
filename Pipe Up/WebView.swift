//
//  WebView.swift
//  Pipe Up
//
//  Created by Justin Risner on 6/21/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
