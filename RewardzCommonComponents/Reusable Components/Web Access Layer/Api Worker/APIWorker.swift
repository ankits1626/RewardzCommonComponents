//
//  APIWorker.swift
//  SKOR
//
//  Created by Rewardz on 09/09/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import UIKit

public enum HTTPMethod: String {
    case DELETE = "DELETE"
    case GET = "GET"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH = "PATCH"
    case POST = "POST"
    case PUT = "PUT"
}

let UNAUTHORIZED = 401

/*extension Int {
 public var isOK : Bool{
 if 200 ... 299 ~= self {
 return true
 }
 return false
 }
 }*/

typealias ApiCallCompletionHandler<T> = (APICallResult<T>) -> Void
public let REQUEST_TIME_OUT = 40

public protocol BaseURLProviderProtocol {
    func baseURLString() -> String?
}
public protocol TokenProviderProtocol {
    func fetchAccessToken() -> String?
    func getDeviceSelectedLanguage() -> String
    func fetchUserAgent() -> String
}
protocol DeviceInfoProviderProtocol {
    func getDeviceInfo() -> String
}
protocol RequestSynthesizer {
    func synthesizeRequest(apiRequest : URLRequest , httpBody: Data?) -> URLRequest
}
protocol CommonAPIProtocol {
    associatedtype ParserType : DataParserProtocol
    var apiRequestProvider : APIRequestGeneratorProtocol {get}
    var dataParser : ParserType{get}
    func callAPI(completionHandler: @escaping (APICallResult<ParserType.ResultType>) -> Void)
}
public protocol DataParserProtocol {
    associatedtype ExpectedRawDataType
    associatedtype ResultType
    func parseFetchedData(fetchedData : ExpectedRawDataType) -> APICallResult<ResultType>
}

public protocol APIRequestGeneratorProtocol {
    var urlBuilder : ParameterizedURLBuilder{get set}
    var requestBuilder : APIRequestBuilderProtocol{get set}
    var apiRequest : URLRequest? {get}
}


public enum APICallResult<ResultType>{
    case Success (result : ResultType)
    case SuccessWithNoResponseData
    case Failure (error : APIError)
}

public enum APIError : Error , Equatable{
    case CannotFetch
    case UnexpectedResult
    case ResponseError (statusCode : Int , errorMessage : String?)
    case Others (String)
  case notFound
    
    public func displayableErrorMessage() -> String {
        switch self {
        case .CannotFetch:
            return NSLocalizedString("Unable to fetch", comment: "")
        case .Others(let error):
            return error
        case .ResponseError(let statusCode, let errorMessage):
            if let unwrappedError = errorMessage{
                return unwrappedError
            }else{
                return HTTPURLResponse.localizedString(forStatusCode: statusCode)
            }
        case .UnexpectedResult:
            return NSLocalizedString("Unexpected response is received.", comment: "")
        case .notFound:
          return "Not Found"//.localized
      }
    }
    
    func errorStatusCode() -> Int? {
        switch self {
        case .ResponseError(let statusCode, _):
            return statusCode
        default:
            return nil
        }
    }
}

public func ==(lhs: APIError, rhs: APIError) -> Bool{
    switch (lhs, rhs) {
    case (.CannotFetch, .CannotFetch) : return true
    case (.UnexpectedResult, .UnexpectedResult): return true
    case (.ResponseError(let a1, let b1), .ResponseError(let a2, let b2)) where ((a1 == a2) && (b1 == b2)): return true
    case (.Others(let a), .Others(let b)) where a == b: return true
    default: return false
    }
}

public protocol LogoutResponseHandler{
    func handleLogoutResponse()
}

public class CommonAPICall<P: DataParserProtocol> : CommonAPIProtocol {
    typealias ParserType = P
    var apiRequestProvider: APIRequestGeneratorProtocol
    var dataParser: P
    var logouthandler : LogoutResponseHandler
    
    public init(apiRequestProvider: APIRequestGeneratorProtocol, dataParser: P, logouthandler : LogoutResponseHandler) {
        self.apiRequestProvider = apiRequestProvider
        self.dataParser = dataParser
        self.logouthandler = logouthandler
    }
    
    private func logoutAppforAuthondicationError () {
        logouthandler.handleLogoutResponse()
    }

    public func callAPI(completionHandler: @escaping (APICallResult<P.ResultType>) -> Void)  {
        if let urlRequest = apiRequestProvider.apiRequest{
            let apiTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                let apiCallResult : APICallResult<P.ResultType>!
                if let unwrappedError = error{
                    apiCallResult = APICallResult.Failure(error: APIError.Others(unwrappedError.localizedDescription))
                }else{
                    if let httpResponse = response as? HTTPURLResponse{
                        if httpResponse.statusCode.isUnauthorized{
                            self.logoutAppforAuthondicationError()
                            return // [TO:Do] this should not be return
                        }
                        if httpResponse.statusCode.isOK{
                            if let unwrappedData = data{
                                if let fetchedJSON  = (try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableLeaves)) as? P.ExpectedRawDataType{
                                    apiCallResult = self.dataParser.parseFetchedData(fetchedData: fetchedJSON)
                                }else if let responseStr = String(data: unwrappedData, encoding: String.Encoding.utf8)as? P.ExpectedRawDataType{
                                    apiCallResult = self.dataParser.parseFetchedData(fetchedData: responseStr)
                                }else{
                                    apiCallResult = APICallResult.Failure(error: APIError.UnexpectedResult)
                                }
                            }else{
                                apiCallResult = APICallResult.SuccessWithNoResponseData
                            }
                        }else{
                            var errorMessage : String?
                            if let unwrappedData = data{
                                if let fetchedJSON  = (try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableLeaves)){
                                    if let dictionary = fetchedJSON as? NSArray {
                                        if let errorDetail = dictionary[0]as? String{
                                            errorMessage = errorDetail
                                        }
                                    }
                                    else if let dictionary = fetchedJSON as? NSDictionary {
                                        if let errorvalues = dictionary.allValues.first as? NSArray
                                        {
                                            let errorkey = dictionary.allKeys.first as? String ?? ""
                                            let value = errorvalues[0]as? String ?? ""
                                            errorMessage = "\(errorkey): \(value)"
                                        }
                                    }
                                }
                            }
                            apiCallResult = APICallResult.Failure(error: APIError.ResponseError(statusCode: httpResponse.statusCode, errorMessage: errorMessage))
                        }
                        
                    }else{
                        apiCallResult = APICallResult.Failure(error: APIError.Others(NSLocalizedString("Unknown Response.", comment: "")))
                    }
                }
                completionHandler(apiCallResult)
            }
            apiTask.resume()
        }else{
            completionHandler(APICallResult.Failure(error: APIError.Others(NSLocalizedString("Invalid request", comment: ""))))
        }
    }
}

//MARK:- Providers


public class DeviceInfoProvider: DeviceInfoProviderProtocol {
    public init(){}
    public func getDeviceInfo() -> String {
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let appVersion = nsObject as! String
      
        let build: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject?
        let buildVersion = build as! String
      
        //OS Version
        let OSVersion = UIDevice.current.systemVersion
        
        //iOS Model and Make
        let deviceType = UIDevice.current.deviceType.rawValue
        return "iOS | " + deviceType + " | " + OSVersion + " | " + appVersion + " | " + buildVersion 
    }
}

extension Int {
    public var isOK : Bool {
        if 200 ... 299 ~= self {
            return true
        }
        return false
    }
    public var isUnauthorized : Bool {
        if 401 == self {
            return true
        }
        return false
    }
}
