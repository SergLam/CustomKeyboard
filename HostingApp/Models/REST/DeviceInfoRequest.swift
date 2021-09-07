//
//  DeviceInfoRequest.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 03.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

//struct DeviceInfoRequest: Codable {
//    
//    var deviceId: String
//    var uuid: String
//    var data: String
//        
//    enum CodingKeys: String, CodingKey {
//        case deviceId = "device_id"
//        case uuid = "uuid"
//        case data = "data"
//        case token = "device_token"
//    }
//    
//    init?(appVersion: String) {
//        
//        deviceType = "OS/iPhone"
//        iphoneNumber = UIDevice.current.machineName()
//        deviceVersion = UIDevice.current.systemVersion
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        deviceType = try container.decode(String.self, forKey: .deviceType)
//        iphoneNumber = try container.decode(String.self, forKey: .iphoneNumber)
//        deviceVersion = try container.decode(String.self, forKey: .deviceVersion)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(deviceType, forKey: .deviceType)
//        try container.encodeIfPresent(iphoneNumber, forKey: .iphoneNumber)
//        try container.encodeIfPresent(deviceVersion, forKey: .deviceVersion)
//    }
//    
//}
//
//// MARK: - JSONAble
//extension DeviceInfoRequest: JSONAble {
//    
//    func toJSON() -> [String: Any] {
//        var result: [String: Any] = [:]
//        result[CodingKeys.deviceType.rawValue] = deviceType
//        result[CodingKeys.iphoneNumber.rawValue] = iphoneNumber
//        result[CodingKeys.deviceVersion.rawValue] = deviceVersion
//        return result
//    }
//    
//}

//
//// *************************** save device id to keychain
//    if(![NS_Defaults objectForKey:kDEVICE_ID])
//    {
//        KeychainItemWrapper *item=[[KeychainItemWrapper alloc] initWithIdentifier:App_Name accessGroup:Nil];
////                [item resetKeychainItem];
//        NSString *obj=[NSString stringWithFormat:@"%@",[item.keychainItemData objectForKey:(__bridge id)(kSecAttrAccount)]];
//
//        if([obj isEqualToString:@""] || !obj)
//        {
//            UIDevice *device = [UIDevice currentDevice];
//            obj = [[device identifierForVendor] UUIDString];
//            [item setObject:obj forKey:(__bridge id)(kSecAttrAccount)];
//        }
//        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.dasquire.app.keyboard"];
//
//        [myDefaults setObject:obj forKey:@"device_id"];
//        [myDefaults synchronize];
//
//        [NS_Defaults setObject:obj forKey:kDEVICE_ID];
//        [NS_Defaults synchronize];
//    }
//
//    // ***************************
//
//    self.strDEVICE_ID = [NS_Defaults objectForKey:kDEVICE_ID];
//
//    NSMutableDictionary *d=[[NSMutableDictionary alloc]init];
//
//    [d setObject:[utility getTimeZone] forKey:@"timezone_info"];
//
//#if !TARGET_IPHONE_SIMULATOR
//
//    d=[ALSystem getDeviceInfo:d];
//#endif
//
//    d=[ALSystem getLocalizeInfo:d];
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];
//
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    NSMutableDictionary *dicParam=[[NSMutableDictionary alloc]init];
//    [dicParam setObject:self.strDEVICE_ID forKey:@"uuid"];
//    [dicParam setObject:jsonString forKey:@"data"];
//    [dicParam setObject:@"" forKey:@"device_token"];
