//
//  CustomAlamofireSession.swift
//  HostingApp
//
//  Created by Serhii Liamtsev on 9/8/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Alamofire
import Foundation

final class CustomAlamofireSession: Alamofire.Session {
    
    private static let requestTimeOutTimeInterval: TimeInterval = {
        // TODO: Home screen API (/get_homescreen_full) doesn't support pagination
        // So it cause request failure for heavy users / moderators (who have more that 1000 chats)
        // In order to prevent it - increase a request timeout timeinterval
        // Should be removed while server side will introduce pagination
        return AppConstants.requestTimeOutTimeInterval
    }()
    
    final class func defaultAlamofireSession() -> Session {
        
        let configuration = URLSessionConfiguration.default
        configuration.isDiscretionary = false
        configuration.waitsForConnectivity = true
        configuration.sessionSendsLaunchEvents = true
        configuration.headers = .default
        if #available(iOS 13.0, *) {
            configuration.allowsExpensiveNetworkAccess = true
            configuration.allowsConstrainedNetworkAccess = true
        } else {
            
        }
        configuration.timeoutIntervalForRequest = requestTimeOutTimeInterval
        configuration.timeoutIntervalForResource = requestTimeOutTimeInterval
        configuration.sharedContainerIdentifier = AppConstants.urlSessionSharedIdentifier
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
    
}
