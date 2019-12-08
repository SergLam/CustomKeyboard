//
//  BluetoothManager.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import CoreBluetooth
import Foundation

class BluetoothManager: NSObject {
    
    private let manager: CBCentralManager
    
    var isBluthoothEnabled: Bool = false
    
    override init() {
        manager = CBCentralManager(delegate: nil,
                                   queue: DispatchQueue.main,
                                   options: [CBCentralManagerOptionShowPowerAlertKey: false])
        super.init()
        manager.delegate = self
        manager.scanForPeripherals(withServices: nil, options: nil)
    }
    
}

// MARL - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            
        case .unknown, .resetting, .unsupported, .unauthorized:
            isBluthoothEnabled = false
            
        case .poweredOff:
            isBluthoothEnabled = false
            
        case .poweredOn:
            isBluthoothEnabled = true
        }
    }
    
}
