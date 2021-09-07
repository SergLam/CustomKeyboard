//
//  AppConstants.swift
//  HostingApp
//
//  Created by Serhii Liamtsev on 9/8/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

struct AppConstants {
    
    static let requestTimeOutTimeInterval: TimeInterval = 60.0 * 5
    
    static let dateDecodingFormat: JSONDecoder.DateDecodingStrategy = JSONDecoder.DateDecodingStrategy.secondsSince1970
    static let dateEncodingFormat: JSONEncoder.DateEncodingStrategy = JSONEncoder.DateEncodingStrategy.secondsSince1970
    
    static let urlSessionSharedIdentifier: String = "group.custom-keyboard.apps"
}
