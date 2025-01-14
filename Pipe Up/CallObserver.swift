//
//  CallObserver.swift
//  Pipe Up
//
//  Created by Justin Risner on 1/10/25.
//

import CallKit

class CallObserver: NSObject, ObservableObject {
    private var callObserver: CXCallObserver?
    @Published var isCallActive: Bool = false
    
    override init() {
        super.init()
        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue: nil)
    }
}

extension CallObserver: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        // If the device is currently on a call, set isCallActive to true
        if call.hasConnected && !call.hasEnded {
            DispatchQueue.main.async {
                self.isCallActive = true
            }
        } else {
            DispatchQueue.main.async {
                self.isCallActive = false
            }
        }
    }
}
