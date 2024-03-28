//
//  APIWorker.swift
//  SKOR
//
//  Created by Rewardz on 09/09/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import UIKit
import Security
import CommonCrypto

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
public let REQUEST_TIME_OUT = 60

public protocol BaseURLProviderProtocol {
    func baseURLString() -> String?
}
public protocol TokenProviderProtocol {
    func fetchAccessToken() -> String?
    func fetchToken() -> String?
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
    private let sessionSecurityManager = SessionSecurityManager()
    
    public init(apiRequestProvider: APIRequestGeneratorProtocol, dataParser: P, logouthandler : LogoutResponseHandler) {
        self.apiRequestProvider = apiRequestProvider
        self.dataParser = dataParser
        self.logouthandler = logouthandler
    }
    
    private func logoutAppforAuthondicationError () {
        logouthandler.handleLogoutResponse()
    }
    
    func checkifSSLPinningRequired() -> Bool {
        if let devServer = apiRequestProvider.apiRequest?.url?.absoluteString.contains("skordev.com"),
            devServer == true{
            return false
        }
        
        if let userAgent =  apiRequestProvider.apiRequest?.allHTTPHeaderFields?.keys.contains("User-Agent"),
           userAgent == true{
            return true
        }
        
        return false
    }

    public func callAPI(completionHandler: @escaping (APICallResult<P.ResultType>) -> Void)  {
        var session = URLSession(configuration: .default)
        if checkifSSLPinningRequired() {
            session = URLSession(configuration: .ephemeral, delegate: sessionSecurityManager, delegateQueue: nil)
        }
        
        if let urlRequest = apiRequestProvider.apiRequest{
            let apiTask = session.dataTask(with: urlRequest) { (data, response, error) in
//            let apiTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
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
                                        }else if let  unwrappedError = dictionary.object(forKey: "error") {
                                            errorMessage = "\("Error"): \(unwrappedError)"
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
        //appname
        if let unwrappedBundleName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
            if unwrappedBundleName == "Küdos2U" {
                return "iOS | " + deviceType + " | " + OSVersion + " | " + appVersion + " | " + buildVersion + " | " + "Kudos"
            }
            return "iOS | " + deviceType + " | " + OSVersion + " | " + appVersion + " | " + buildVersion + " | " + unwrappedBundleName
        }
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

//reference - https://stackoverflow.com/questions/34223291/ios-certificate-pinning-with-swift-and-nsurlsession
//https://medium.com/@anuj.rai2489/ssl-pinning-254fa8ca2109

public class SessionSecurityManager : NSObject, URLSessionDelegate {
     private let rsa2048Asn1Header:[UInt8] = [
         0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
         0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
     ]

     private func sha256(data : Data) -> String {
         var keyWithHeader = Data(rsa2048Asn1Header)
         keyWithHeader.append(data)
         var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))

         keyWithHeader.withUnsafeBytes {
             _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
         }


         return Data(hash).base64EncodedString()
     }

     private func publicKey(for certificate: SecCertificate) -> SecKey? {
         if #available(iOS 12.0, *) {
             return SecCertificateCopyKey(certificate)
         } else if #available(iOS 10.3, *) {
             return SecCertificateCopyPublicKey(certificate)
         } else {
             var possibleTrust: SecTrust?
             SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
             guard let trust = possibleTrust else { return nil }
             var result: SecTrustResultType = .unspecified
             SecTrustEvaluate(trust, &result)
             return SecTrustCopyPublicKey(trust)
         }
     }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

         guard let serverTrust = challenge.protectionSpace.serverTrust else {
             completionHandler(.cancelAuthenticationChallenge, nil);
             return
         }
         //below are public keys of prod and dev environment
         let localKeys = ["KWwYFzqedu8QIT+u9lVCj2w+6nvzqYr+wJlWLzWrTyQ=",//cerra SG
                          "l6lleDp5z4Xa6RO5bA3/L44+mSlz7fVZbcMbk7fgQDU=", //Cerra MY
                          "rWZnyaljE8H3cUOVjyAa0B5Uz5giTCuU7xpvdYT7xEk=", //Cerra AE
                          "MGKEhVcPy5fQwGWFdJlY3i83t7QPkC78pCxGiXVvv40=", //Cerra IN
                          "f/yaAhNI1DDX8D+cGJMC1tFEiEhdhmfU0q2zVzUXh8Y=",//thanks server
                          "DNFrbvuo/tvZWLk2jhKw/be6d/zP6tIvn80/U8QpnDM=", //https://app.thankabundantly.com/
                          "9RFm1fL58bCkVQ/pgADM1AYwCKIEIp+KWRVEboELANQ=",//akshay server
                          "v0wd7h7DBYLa0ChZBlP1qhoyilhbTfuAcSy3eE3Kv50=",//ashutosh server
                          "nGi+rHX7HmiSJK45PL6uxyE6NXki3SWPNhs2XgZ/IaI=", //dryice server
                          "NbgCEaRyzcOO5MVuqtnQitf+HZjXhSp3awrfXnqspYw=", //govind server
                          "NIe25q4jQJaGXU3R02aSdpMtJzjxI48v5398lnuCQVE=",//jack server
                          "oPuLkDR4fH7o2P/hGxis/o6qAzPKE9Y2EEEFJepIL10=", //jerry server
                          "pQxuW6smpF4SBN7hLsZM4yjd8Sh4AA4QiZqEMNQHcm4=", // prashant server
                          "eZQBsuP+Gp+Nr9bzd/aqjciw91lbqcZJV37JZhky9wA=", // prateek server
                          "i2wlO7Mgk2MLPu7OIewfwENNIpZ9JDGGpo75aRYTm+o=", //raghvendra server
                          "HzTNMZBLPk7qFmuHsP+SNWJ7pFZmSHKWm/DNP5osPZM=", //rishi server
                          "JoyO3Eclw4R0npBIBMN4UG/O7ffVWa2VvXEuTP/wkqI=", //tom server
                          "Hj7Z6lG7WGSyve9mG/JUrMyDwj9GDnd1v7z8ZckL+kU=", //amolc server
                          "ZO2OOGIuoQQTL/R/eOyPUiaqghVmVJsF5RIGvG1yGkI=", //nuhs server
                          "w1Vsvjsu62LmV6TCKg/TxjMorYaik82tQ8lfNccjcfA=", //piklu.skordev
                          "m1RMmz8OhN3+NNMyZD4fRdyrJwu5mQFm5fsPjLPWV/c=",//shashi.skordev
                          "M/K3Q4w7Nnlu1Vh1+CIMLm3NRycafljc2HkDwhhXNKI=",//mario.skordev
                          "CcMiYeVEeuBA3FsulyTHjDWAgxfbjKM3At7ijVUUA+I="] //skordev
                          

         if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
            let serverPublicKey = publicKey(for: serverCertificate),
            let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ){
             let data:Data = serverPublicKeyData as Data
             // Server Hash key
             let serverHashKey = sha256(data: data)
             // Local Hash Key
             if (localKeys.contains(serverHashKey)) {
                 // Success! This is our server."Public key pinning is successfully completed"
                 completionHandler(.useCredential, URLCredential(trust:serverTrust))
                 return
             }else{
                 completionHandler(.cancelAuthenticationChallenge, nil)
             }
         }else{
             completionHandler(.cancelAuthenticationChallenge, nil)
         }
     }

 }
