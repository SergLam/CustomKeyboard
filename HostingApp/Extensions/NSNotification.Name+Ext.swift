//
//  NSNotification.Name+Ext.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

enum NotificationName: String, CaseIterable {
    
    // Network states handling
    case didLostConnection
    case didRestoreConnection
    case didReceiveError
    case didFailToSendData
}

extension NSNotification.Name {
    
    /// Show progress bar
    public static let socketLostConnection = Notification.Name(  "\(NotificationService.bundle).\(NotificationName.didLostConnection.rawValue)")
    
    /// Hide progress bar
    public static let socketRestoredConnection = Notification.Name( "\(NotificationService.bundle).\(NotificationName.didRestoreConnection.rawValue)")
    
}
