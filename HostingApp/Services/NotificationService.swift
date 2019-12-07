//
//  NotificationService.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

import UIKit

// MARK: Since all socket data received through one event ('message') - best way to handle it for different screens and states - use notifications (or RxSwift)
class NotificationService {
    
    static let bundle = Bundle.main.bundleIdentifier ?? ""
    static let shared = NotificationService()
    
    func postNotification(name: NSNotification.Name, _ info: [String: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: self, userInfo: info)
    }
    
}
