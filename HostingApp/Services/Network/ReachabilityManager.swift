//
//  ReachabilityManager.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    static var reachability: Reachability? = try? Reachability()
    
    var isNetworkAvailable: Bool {
        return reachabilityStatus != .none
    }
    
    var reachabilityStatus: Reachability.Connection = reachability?.connection ?? .unavailable
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: ReachabilityManager.reachability)
        do{
            try ReachabilityManager.reachability?.startNotifier()
        } catch {
            assert(false, "Could not start reachability notifier")
        }
    }
    
    @objc
    func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else {
            assert(false, "Unable to cast notification")
            return
        }
        switch reachability.connection {
        case .none, .unavailable:
            reachabilityStatus = reachability.connection
            NotificationService.shared.postNotification(name: .socketLostConnection)
            
        case .wifi:
            reachabilityStatus = .wifi
            NotificationService.shared.postNotification(name: .socketRestoredConnection)
            
        case .cellular:
            reachabilityStatus = .cellular
            NotificationService.shared.postNotification(name: .socketRestoredConnection)
        }
    }
    
}
