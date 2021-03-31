//
//  URLGenerator.swift
//  SKOR
//
//  Created by Rewardz on 09/09/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import Foundation
public class ParameterizedURLBuilder {
    var baseURLProvider : BaseURLProviderProtocol
    public init(baseURLProvider : BaseURLProviderProtocol){
        self.baseURLProvider = baseURLProvider
    }
    
    public func getURL(endpoint: String, parameters: [String:String]?) -> URL? {

        if let  baseURLString = baseURLProvider.baseURLString(){
            var components = URLComponents(string: baseURLString + endpoint)!
            var queryItems = [URLQueryItem]()
            let baseParams: [String: String] = [:]
            for (key, value) in baseParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            if let aditionalParams = parameters {
                for (key, value) in aditionalParams {
                    let item = URLQueryItem(name: key, value: value)
                    queryItems.append(item)
                }
            }
            if queryItems.count > 0 {
                components.queryItems = queryItems
            }
            return components.url
        }
        return nil
    }

    public func getURLWithMultipleSameQueryKeys(endpoint: String, parameters: [String:[String]]?) -> URL? {
        if let  baseURLString = baseURLProvider.baseURLString(){
            var components = URLComponents(string: baseURLString + endpoint)!
            var queryItems = [URLQueryItem]()
            let baseParams: [String: String] = [:]
            for (key, value) in baseParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            if let aditionalParams = parameters {
                for (key, value) in aditionalParams {
                    value.forEach { (aValue) in
                        let item = URLQueryItem(name: key, value: aValue)
                        queryItems.append(item)
                    }
                }
            }
            if queryItems.count > 0 {
                components.queryItems = queryItems
            }
            return components.url
        }
        return nil
    }
}
