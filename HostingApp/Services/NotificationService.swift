//
//  NotificationService.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

import UIKit

class NotificationService {
    
    static let shared = NotificationService()
    
    static let bundle = Bundle.main.bundleIdentifier ?? "CustomKeyboard"
    
    func postNotification(name: NSNotification.Name, _ info: [String: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: self, userInfo: info)
    }
    
}
