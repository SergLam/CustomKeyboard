//
//  UIDevice+Ext.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 03.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

extension UIDevice {
    
    func machineName() -> String {
      var systemInfo = utsname()
      uname(&systemInfo)
      let machineMirror = Mirror(reflecting: systemInfo.machine)
      return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
    }
    
}
