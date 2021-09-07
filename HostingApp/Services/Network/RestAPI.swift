//
//  RestAPI.swift
//  HostingApp
//
//  Created by Serhii Liamtsev on 9/7/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Alamofire
import Foundation
import Moya

final class RestAPI {
    
    let provider = MoyaProvider<CustomKeyboard>(session: CustomAlamofireSession.defaultAlamofireSession(),
                                                plugins: RestAPI.provideNetworkPlugin())
    
    // MARK: - Private functions
    private static func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
    
    private static func JSONRequestDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            guard let result = String(data: prettyData, encoding: String.Encoding.utf8) else {
                return String(decoding: data, as: UTF8.self)
            }
            return result
        } catch {
            return String(decoding: data, as: UTF8.self)
        }
    }
    
    private static func provideNetworkPlugin() -> [PluginType] {
        
        // NOTE: Network logger cause app struck for heavy users (30 MB of JSON data)
        let plugin: NetworkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONRequestDataFormatter), logOptions: .verbose))
        #if DEBUG
        return [plugin]
        #elseif DEBUG_MOCKAPI
        return [plugin]
        #else
        return []
        #endif
    }
}
