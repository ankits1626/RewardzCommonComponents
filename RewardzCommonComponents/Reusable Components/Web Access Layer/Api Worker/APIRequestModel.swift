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
    func apiRequestWithMultiPartFormHeader( url: URL?, method : HTTPMethod , httpBodyString : String?) -> URLRequest?
    func apiRequestWithHttpParamsAggregatedHttpParamsForInspireMe( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?
    func apiRequestWithSubscriptionInAuthorizationHeader( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?
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
    
    public func apiRequestWithSubscriptionInAuthorizationHeader( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?{
        if let unwrappedURL = url{
            var apiRequest = URLRequest(url: unwrappedURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(REQUEST_TIME_OUT))
            apiRequest.httpMethod = method.rawValue
            apiRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            apiRequest.addValue("799d4ac2b74e4fb799af1da6bcea2d0a", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
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
    
    public func apiRequestWithHttpParamsAggregatedHttpParamsForInspireMe( url: URL?, method : HTTPMethod , httpBodyDict : NSDictionary?) -> URLRequest?{
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
            
            apiRequest.addValue("Basic b2b_3fd519b770be7fabf1aec1439e79a2503235e2655a6965a5e6b5c52bedd64b10", forHTTPHeaderField: "Authorization")
            return apiRequest
        }else{
            return nil
        }
    }
    
    public func apiRequestWithMultiPartFormHeader( url: URL?, method : HTTPMethod , httpBodyString : String?) -> URLRequest?{
        if let unwrappedURL = url{
            var apiRequest = URLRequest(url: unwrappedURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(REQUEST_TIME_OUT))
            apiRequest.httpMethod = method.rawValue
            let params = httpBodyString!
            let dataa = params.data(using: .utf8)
            apiRequest.httpBody = dataa
            apiRequest.setValue("\(tokenProvider.fetchUserAgent()) \(deviceInfoProvider.getDeviceInfo())", forHTTPHeaderField: "User-Agent")
            apiRequest.addValue("keep-alive", forHTTPHeaderField: "Connection")
            apiRequest.addValue(tokenProvider.getDeviceSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
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
