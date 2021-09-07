//
//  JSONAble.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 03.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

public protocol JSONAble {
    func toJSON() -> [String: Any]
}
