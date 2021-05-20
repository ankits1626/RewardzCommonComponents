//
//  APIRequestModel.swift
//  SKOR
//
//  Created by Rewardz on 09/09/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import Foundation


public protocol APIRequestBuilderProtocol {
    func apiRequestWithNoAuthorizationHeader( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?
    func apiRequestWithHttpParamsAggregatedHttpParams( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?
    func apiRequestWithnobodydictHttpParamsAggregatedHttpParams( url: URL?, method : HTTPMethod , httpBodyDict : Data) -> URLRequest?
}

public class APIRequestBuilder : APIRequestBuilderProtocol {
    var tokenProvider :  TokenProviderProtocol
    var deviceInfoProvider : DeviceInfoProviderProtocol = DeviceInfoProvider()
    public init(tokenProvider :  TokenProviderProtocol){
        self.tokenProvider = tokenProvider
    }
    /*public func apiRequestWithNoAuthorizationHeader( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?{
        if let unwrappedURL = url{
            var apiRequest = URLRequest(url: unwrappedURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(REQUEST_TIME_OUT))
            apiRequest.httpMethod = method.rawValue
            apiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            apiRequest.addValue("keep-alive", forHTTPHeaderField: "Connection")
            apiRequest.addValue(tokenProvider.getDeviceSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
            //apiRequest.setValue("\(appName()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            apiRequest.setValue("\(tokenProvider.fetchUserAgent()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            apiRequest.addValue(tokenProvider.getDeviceSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
            if let unwrappedHttpBody = httpBodyDict{
                if let httpBody  = (try? JSONSerialization.data(withJSONObject: unwrappedHttpBody, options: .prettyPrinted)){
                    apiRequest.httpBody = httpBody
                }
            }
            return apiRequest
        }else{
            return nil
        }
    }*/
    public func apiRequestWithNoAuthorizationHeader( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?{
        if let unwrappedURL = url{
            var apiRequest = URLRequest(url: unwrappedURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(REQUEST_TIME_OUT))
            apiRequest.httpMethod = method.rawValue
            apiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            apiRequest.addValue("keep-alive", forHTTPHeaderField: "Connection")
            apiRequest.setValue("\(tokenProvider.fetchUserAgent()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            
            if let unwrappedHttpBody = httpBodyDict{
                if let httpBody  = (try? JSONSerialization.data(withJSONObject: unwrappedHttpBody, options: .prettyPrinted)){
                    apiRequest.httpBody = httpBody
                }
            }
            return apiRequest
        }else{
            return nil
        }
    }
    // api request with no body dict
    public func apiRequestWithnobodydictHttpParamsAggregatedHttpParams( url: URL?, method : HTTPMethod , httpBodyDict : Data) -> URLRequest?{
        if let unwrappedURL = url{
            var apiRequest = URLRequest(url: unwrappedURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(REQUEST_TIME_OUT))
            apiRequest.httpMethod = method.rawValue
            apiRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            apiRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            apiRequest.addValue(tokenProvider.getDeviceSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
            apiRequest.setValue("\(tokenProvider.fetchUserAgent()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            apiRequest.httpBody = httpBodyDict
            if let authorizationHeaderValue = self.tokenProvider.fetchAccessToken(){
                apiRequest.addValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            }
            return apiRequest
        }else{
            return nil
        }
    }
    
    public func apiRequestWithHttpParamsAggregatedHttpParams( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?{
        if let unwrappedURL = url{
            var apiRequest = URLRequest(url: unwrappedURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(REQUEST_TIME_OUT))
            apiRequest.httpMethod = method.rawValue
            apiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            apiRequest.addValue("keep-alive", forHTTPHeaderField: "Connection")
//            apiRequest.setValue("\(appName()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            apiRequest.setValue("\(tokenProvider.fetchUserAgent()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            apiRequest.addValue(tokenProvider.getDeviceSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
            if let unwrappedHttpBody = httpBodyDict{
                if let httpBody  = (try? JSONSerialization.data(withJSONObject: unwrappedHttpBody, options: [])){
                    apiRequest.httpBody = httpBody
                }
            }
            if let authorizationHeaderValue = self.tokenProvider.fetchAccessToken(){
                apiRequest.addValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            }
            return apiRequest
        }else{
            return nil
        }
    }
  
  func appName() -> String {
    let appName: AnyObject? = Bundle.main.infoDictionary!["CFBundleName"] as AnyObject?
    return appName as? String ?? ""
  }
}
