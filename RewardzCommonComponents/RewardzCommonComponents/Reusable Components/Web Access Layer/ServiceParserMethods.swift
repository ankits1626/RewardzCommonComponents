//
//  ServiceParserMethods.swift
//  Flabuless
//
//  Created by RIS on 03/02/15.
//  Copyright (c) 2015 Rewardz Private Limited. All rights reserved.
//

import UIKit
import CoreLocation
import Reachability
import RxSwift

var UrlMain: String  { return getServiceURL()}

struct Rest200ErrorResponse: Decodable {
  let nonFieldErrors: [String]?
  let password: [String]?
}

struct InvalidPostalCodeError: Decodable {
  let status: Int
  let message: String
}

typealias CommonError = [String]

class ServiceParserMethods: NSObject {
    
    var tag:Int32!
    
    override init() {
        
        super.init()
        
        self.tag = 0;
    }

  func getloginToken(_ email: String, password: String ,has_mobile_data : String ,registration_id : String ,device_type : String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
    if Reachability()!.connection == Reachability.Connection.none {
      completionClosure(NSDictionary())
      ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
      return;
    }
    
    let request = NSMutableURLRequest(url: URL(string: UrlMain+"api-token-auth/")!)
    request.timeoutInterval = 60
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.httpMethod = "POST"
    var params = ""
    
    let pushToken = getApnsToken()
    let deviceid = getDeviceId()
    
    if pushToken.isEmpty {
      params = "username=\(email)&password=\(password)" as String
    }
    else {
      params = "username=\(email)&password=\(password)&has_mobile_data=\(1)&registration_id=\(pushToken)&device_id=\(deviceid)&device_type=iOS" as String
    }
    
    let dataa = params.data(using: .utf8)
    request.httpBody = dataa
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          if let jsonData:NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
            completionClosure(jsonData)
          }
          else {
            completionClosure(NSDictionary())
          }
        }
        else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          }
          else {
            // Authondication error, We should Logout
            completionClosure(NSDictionary())
          }
        }
        else if statusCode >= 500 {
          // Server error, try later
          completionClosure(NSDictionary())
        }
      }
      else {
        completionClosure(NSDictionary())
      }
    })
    postDataTask.resume()
  }
    
  func getTokenForBenefit(_ email: String, password: String, hasMobileData: String, registrationId: String, deviceType: String, completionClosure: @escaping (_ results: LoginResponse?, _ error: APIError?) -> Void) {
    if Reachability()!.connection == Reachability.Connection.none {
      completionClosure(nil, APIError.Others("Login:NoNetwork".localized))
    }

    let request = NSMutableURLRequest(url: URL(string: UrlMain+"api-token-auth/")!)
    request.timeoutInterval = 60
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.httpMethod = "POST"
    var params: String = ""

    let pushToken = getApnsToken()
    let deviceid = getDeviceId()

    if pushToken.isEmpty {
      params = "username=\(email)&password=\(password)"
    } else {
      params = "username=\(email)&password=\(password)&has_mobile_data=\(1)&registration_id=\(pushToken)&device_id=\(deviceid)&device_type=iOS"
    }
    let dataa = params.data(using: .utf8)
    request.httpBody = dataa
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          guard let data = data else {
            fatalError("'ServiceParserMethods' data found to be nil in 'getLoginToken'.")
          }
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let loginResponse = try decoder.decode(LoginResponse.self, from: data)
            completionClosure(loginResponse, nil)
          } catch _ {
            if let errorResponse = try? decoder.decode(Rest200ErrorResponse.self, from: data) {
              completionClosure(nil, APIError.Others(errorResponse.nonFieldErrors?[0] ?? errorResponse.password![0]))
            } else {
              completionClosure(nil, APIError.Others("Unable to log in with provided credentials."))
            }
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            completionClosure(nil, APIError.notFound)
          }
        } else if statusCode >= 500 {
          completionClosure(nil, APIError.Others("Server error"))
        }
      } else {
        completionClosure(nil, APIError.Others("Server error"))
      }
    })
    postDataTask.resume()
  }
  
  func decodeResponse<T: Decodable>(data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
    return try decoder.decode(T.self, from: data)
  }
  
  func request<T: Decodable>(url: String,
                             method: HTTPMethod,
                             params: [String : Any]? = nil) -> Observable<T> {
    //    return URLSession.shared.rx.response
    var request: URLRequest = URLRequest(url: URL(string: UrlMain+"/challenges/")!)
    request.httpMethod = "GET"
    request.timeoutInterval = 60
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = getUserToken() as String
    request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
    if let params = params {
      request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }
    return URLSession.shared.rx
      .response(request: request)
      .map { response, data in
        if 200...299 ~= response.statusCode {
          return try self.decodeResponse(data: data)
        } else {
          throw NetworkErrorConverter().from(response: response, data: data)
        }
    }
  }

  func getChallenges(completion: @escaping (Result<ChallengeResponse, Error>) -> Void) {
    var request: URLRequest = URLRequest(url: URL(string: UrlMain + "challenges/")!)
    
    request.httpMethod = "GET"
    request.timeoutInterval = 60
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")
    
    let postDataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
      if let statusCode = response?.getStatusCode() {
        guard let data = data else {
          completion(.failure(ApiError.dataFoundToBeNil))
          return
        }
        if statusCode >= 200 && statusCode < 300 {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
          do {
            let challengeResponse = try decoder.decode(ChallengeResponse.self, from: data)
            completion(.success(challengeResponse))
          } catch let error {
            print(error.localizedDescription)
            completion(.failure(ApiError.serverError))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            do {
              let errorResponse = try JSONDecoder().decode(CommonError.self, from: data)
              completion(.failure(APIError.Others(errorResponse[0])))
            } catch _ {
              completion(.failure(ApiError.authenticationError))
            }
          }
        } else if statusCode >= 500 {
          completion(.failure(ApiError.serverError))
        }
      } else {
        completion(.failure(ApiError.badUrl))
      }
    })
    postDataTask.resume()
  }

    ///v2/recover/ 200 reponse code
    func recoverPassword(_ email: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        if Reachability()!.connection == Reachability.Connection.none {
            completionClosure(NSDictionary())
             ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
            return;
        }
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"recover/")!)
        request.timeoutInterval = 60
        request.httpMethod = "POST"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let params = ["email":email] as NSDictionary
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData:NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    // Update Push Token
    func updateToken(_ registration_id : String ,device_id : String,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
      if Reachability()!.connection == Reachability.Connection.none {
        ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
        completionClosure(NSDictionary())
        return;
      }
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"push/")!)
        request.timeoutInterval = 60
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        var params = ""
        
        params = "registration_id=\(registration_id)&device_id=\(device_id)&client=ios" as String
        
        let dataa = params.data(using: .utf8)
        request.httpBody = dataa
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData:NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
  
  func sendPolarToken(_ authorizationHeaderKey : String,authorizationCode : String,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
      
    if Reachability()!.connection == Reachability.Connection.none {
      ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
      completionClosure(NSDictionary())
      return;
    }
      
      let request = NSMutableURLRequest(url: URL(string: "https://polarremote.com/v2/oauth2/token")!)
      request.timeoutInterval = 60
      request.httpMethod = "POST"
      
      request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      request.addValue("Basic "+authorizationHeaderKey, forHTTPHeaderField: "Authorization")
      var params = ""
      let grantType = "authorization_code"
      params = "grant_type=\(grantType)&code=\(authorizationCode)" as String
      
      let dataa = params.data(using: .utf8)
      request.httpBody = dataa
      
      let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
          if let statusCode = response?.getStatusCode() {
              if statusCode >= 200 && statusCode < 300 {
                  // Success response from server
                  if let jsonData:NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                      completionClosure(jsonData)
                  }
                  else {
                      completionClosure(NSDictionary())
                  }
              }
              else if statusCode >= 400 && statusCode < 500 {
                  // Authondication error, We should Logout
                  if statusCode == 401 {
                      self.logoutAppforAuthondicationError()
                  }
                  else {
                      // Authondication error, We should Logout
                      if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                      {
                          let respo : HTTPURLResponse = response as! HTTPURLResponse
                          let arr = jsonResult as NSArray
                          completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                      }
                      else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                      {
                          let respo : HTTPURLResponse = response as! HTTPURLResponse
                        
                          let arr = jsonResult as NSDictionary
                          if let errorvalues = arr.allValues.first as? NSArray
                          {
                              let errorkey = arr.allKeys.first as? String ?? ""
                              let value = errorvalues[0]as? String ?? ""
                              completionClosure(["responseCode":respo.statusCode , "Message" : "\(errorkey): \(value)"])
                          }
                          else
                          {
                              completionClosure(NSDictionary())
                          }
                      }
                      else
                      {
                          completionClosure(NSDictionary())
                      }
                  }
              }
              else if statusCode >= 500 {
                  // Server error, try later
                  completionClosure(NSDictionary())
              }
          }
          else {
              completionClosure(NSDictionary())
          }
      })
      postDataTask.resume()
  }
    
    ///v2/total-­points/ 200-response Code
    func getTotalPoints(_ dateSlected: String, completionClosure: @escaping (_ repos: NSDictionary?) ->())  {
      if Reachability()!.connection == Reachability.Connection.none {
        completionClosure(nil)
        return
      }
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"total-points/" )!)
        request.timeoutInterval = 60
        request.httpMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let params = "date=\(dateSlected)" as String
        let dataa = params.data(using: .utf8)
        request.httpBody = dataa
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization
                      .jsonObject(with: data!,
                                  options: .mutableContainers) as! NSDictionary {
                      completionClosure(jsonData)
                    } else {
                        completionClosure(NSDictionary())
                    }
                } else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    } else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                } else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            } else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/users/current/ 200 response code
    func getUserDetails(_ dateSlected: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
      if Reachability()!.connection == Reachability.Connection.none {
        completionClosure(NSDictionary())
        return
      }
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/current/" )!)
        request.timeoutInterval = 60
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
  func createBodyWithParameters(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data?, boundary: String) -> Data {
      var body: Data = Data()
      if let validParams = parameters {
        for (key, value) in validParams {
          body.append("--\(boundary)\r\n".data(using: .utf8)!)
          body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
          body.append("\(value)\r\n".data(using: .utf8)!)
        }
      }

      if let imageData = imageDataKey {
        let filename = "user-profile.jpg"
        let mimeType = "image/jpg"

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
      }

      return body
  }
    
    ///v2/users/current/
    func updateUserDetails(_ image : UIImage? , dictUserDetails: NSDictionary ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
      if Reachability()!.connection == Reachability.Connection.none {
        completionClosure(NSDictionary())
        ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
        return
      }
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/current/" )!)
        request.httpMethod = "PUT"
        request.timeoutInterval = 60
        let boundary = generateBoundaryString()
        
        let token = getUserToken() as String
        request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard image != nil else {
            request.httpBody = createBodyWithParameters(dictUserDetails as? [String : String], filePathKey: "profile_pic", imageDataKey: nil, boundary: boundary)
            
            let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                if let statusCode = response?.getStatusCode() {
                  guard let validData = data else {
                    fatalError("Data is nil for updated user api")
                  }
                    if statusCode >= 200 && statusCode < 300 {
                        // Success response from server
                        if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: validData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                            completionClosure(jsonData)
                        } else {
                            completionClosure(NSDictionary())
                        }
                    } else if statusCode >= 400 && statusCode < 500 {
                      // Authentication error, We should Logout
                      if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                      } else {
                        if let errorJson = try? JSONSerialization
                          .jsonObject(with: validData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary,
                          let error = errorJson.allValues.first as? [String] {
                          completionClosure(["error": error[0]])
                        } else {
                          completionClosure(NSDictionary())
                        }
                      }
                    } else if statusCode >= 500 {
                      completionClosure(NSDictionary())
                    }
                }
                else {
                    completionClosure(NSDictionary())
                }
            })
            postDataTask.resume()
            
            return
        }
        
        let imageData = image!.jpegData(compressionQuality: 0.3)
        
      request.httpBody = createBodyWithParameters(dictUserDetails as? [String : String], filePathKey: "profile_pic", imageDataKey: imageData, boundary: boundary)
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/activities/ 201 - reponse code
    func saveActivity(_ email: String ,source: String ,activity_type: String ,total_calories: String ,uri: String ,total_distance: NSString ,start_time: String ,end_time: String ,steps: String ,duration: NSString, completionClosure: @escaping (_ repos :NSDictionary) ->())  {
      if Reachability()!.connection == Reachability.Connection.none {
        completionClosure(NSDictionary())
        ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
        return
      }
        
        var type =  activity_type as String
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"activities/")!)
        request.httpMethod = "POST"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.timeoutInterval = 60
        
        if activity_type == "scuba diving"
        {
            type = "scuba_diving"
        }else if activity_type == "table tennis"
        {
            type = "table_tennis"
        }else if activity_type == "indoor cycling"
        {
            type = "indoor_cycling"
        }else if activity_type == "circuit training"
        {
            type = "circuit_training"
        }else if activity_type == "weight training"
        {
            type = "weight_training"
        }else if activity_type == "martial arts"
        {
            type = "martial_arts"
        }else if activity_type == "eliptical training"
        {
            type = "elliptical_training"
        }else if activity_type == "stair climbing"
        {
            type = "stair_climbing"
        }else if activity_type == "work out"
        {
            type = "workout"
        }else if activity_type == "nuhs stairs"
        {
            type = " NUHS_stairs"
        }
        else if activity_type == "washing car"
        {
            type = "washing_car"
        }
        else if activity_type == "sweeping & mopping"
        {
            type = "sweeping_&_mopping"
        }
        else if activity_type == "sweeping & mopping"
        {
            type = "sweeping_&_mopping"
        }
        var durationSeconds = duration.integerValue as NSInteger
        durationSeconds = durationSeconds * 60
        
        var steplocal = steps
        if steplocal.isEmpty {
            steplocal = "0" as String
        }
        
        var params: NSDictionary
        
        if type != " NUHS_stairs" {
            params = ["source":source, "activity_type":type, "total_calories":"0", "uri":uri, "total_distance":"\(Int(total_distance.integerValue*1000))", "start_time":start_time, "steps":steplocal, "duration" : "\(durationSeconds)", "show_error": "X"]
        } else {
            params = ["source":source, "activity_type":type, "total_calories":"0", "uri":uri, "floors":"\(Int(total_distance.integerValue))", "start_time":start_time, "steps":steplocal, "duration" : "\(durationSeconds)", "show_error": "X"]
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                    {
                        let respo : HTTPURLResponse = response as! HTTPURLResponse
                        let arr = jsonResult as NSArray
                        completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                    }else{
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                        {
                            let respo : HTTPURLResponse = response as! HTTPURLResponse
                            let arr = jsonResult as NSArray
                            completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                        }
                        else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                        {
                            let respo : HTTPURLResponse = response as! HTTPURLResponse
                            let arr = jsonResult as NSDictionary
                            if let errorvalues = arr.allValues.first as? NSArray
                            {
                                let errorkey = arr.allKeys.first as? String ?? ""
                                let value = errorvalues[0]as? String ?? ""
                                completionClosure(["responseCode":respo.statusCode , "Message" : "\(errorkey): \(value)"])
                            }
                            else
                            {
                                completionClosure(NSDictionary())
                            }
                        }
                        else
                        {
                            completionClosure(NSDictionary())
                        }
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/steps/ 201 - response
    func saveSteps(_ steps: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"steps/")!)
        request.httpMethod = "POST"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.timeoutInterval = 60
        Logger.log(log: "\(#function) : Savesapi steps : \(steps)")
        let dateEnd: String = getFormattedDateFrom(Date(), dateFormat: "yyyy-MM-dd HH:mm:ssZ")
        
        //App Version
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject?
        let appVersion = nsObject as! String
        
        //OS Version
        let OSVersion = UIDevice.current.systemVersion
        
        //iOS Model and Make
        let deviceType = UIDevice.current.deviceType.rawValue
        
        let device_info = "iOS | " + deviceType + " | " + OSVersion + " | " + appVersion
        //End of Change//
        
        var stepss = steps as String
        if (stepss == ""){
            stepss = "0"
        }
        
        let calories = getCaloriesCount()
        let distance = getDistanceCount()
        let duration = getDurationCount()
        
        let params = ["steps":stepss,"total_calories":calories, "total_distance": distance, "duration": duration, "start_time":dateEnd, "device_info": device_info] as NSDictionary
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        
        Logger.log(log: "\(#function) : appleheath data : \(params)")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    //last updated facility
    func getFacilitiesLastUpdated(completionClosure: @escaping (_ lastUpdated: String) ->()) {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"facilities/last_updated/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    let str = String.init(data: data!, encoding: .utf8)
                    print(str)
                    if let jsonData: NSArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray  {
                        if jsonData.count > 0 {
                            let timeStamp = jsonData.firstObject as? String ?? ""
                            completionClosure(timeStamp)
                        }
                        else {
                            completionClosure("")
                        }
                        print(jsonData)
                    }
                    else {
                        completionClosure("")
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure("")
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure("")
                }
            }
            else {
                completionClosure("")
            }
        })
        postDataTask.resume()
    }
    //last updated reward list
    func getRewardsLastUpdated(completionClosure: @escaping (_ lastUpdated: String) ->()) {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"rewards/last_updated/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSArray = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray  {
                        if jsonData.count > 0 {
                            let timeStamp = jsonData.firstObject as? String ?? ""
                            completionClosure(timeStamp)
                        }
                        else {
                            completionClosure("")
                        }
                        print(jsonData)
                    }
                    else {
                        completionClosure("")
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure("")
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure("")
                }
            }
            else {
                completionClosure("")
            }
        })
        postDataTask.resume()
    }

  // /v2/events/ 200 -reponse code
  func getEvents(_ pk: Int? ,nextUrl:String?, completion: @escaping (_ events: EventsResponse?, _ error: Error?) -> Void)  {
    var request = NSMutableURLRequest()
    request.timeoutInterval = 60
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    if pk == nil {
      if nextUrl != nil && !(nextUrl?.isEmpty)! {
        request = NSMutableURLRequest(url: URL(string: nextUrl!)!)
      }
      else {
        request = NSMutableURLRequest(url: URL(string: UrlMain+"events/")!)
      }
    } else {
      if nextUrl != nil && !(nextUrl?.isEmpty)! {
        request = NSMutableURLRequest(url: URL(string: nextUrl!)!)
      }
      else {
        request = NSMutableURLRequest(url: URL(string: UrlMain+"events/?category_pk=\(pk!)")!)
      }
    }

    request.httpMethod = "GET"

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let token = getUserToken()
    request.addValue("Token "+token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          guard let data = data else {
            completion(nil, InValidDataError())
            return
          }
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let events = try decoder.decode(EventsResponse.self, from: data)
            completion(events, nil)
          } catch let error {
            completion(nil, error)
          }
        } else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            // Authondication error, We should Logout
            completion(nil, InValidDataError())
          }
        } else if statusCode >= 500 {
          // Server error, try later
          completion(nil, InValidDataError())
        }
      } else {
        completion(nil, InValidDataError())
      }
    })
    postDataTask.resume()
  }

    //get CategoryID 200 - reponse code
    func caterogryid(_ completionClosure: @escaping (_ repos :NSDictionary) ->())  {
      if Reachability()!.connection == Reachability.Connection.none {
        completionClosure(NSDictionary())
        ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
        return
      }
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"events/categories/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSMutableArray = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray {
                        completionClosure(["result" : jsonData])
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //Create event 201 - reponse code
    func createEvents(_ image : UIImage?,event : Event,view : UIView, completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        Logger.log(log: "\(#function) : Creating Events Value : \(event.getvalue())")
        
        var request = NSMutableURLRequest()
        request.timeoutInterval = 60
        request = NSMutableURLRequest(url: URL(string: UrlMain+"events/")!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        let token = getUserToken() as String
        request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        guard image != nil else {
            
            request.httpBody = createBodyWithParameters(event.getvalue(), filePathKey: "img", imageDataKey: nil, boundary: boundary)
            
            let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                if let statusCode = response?.getStatusCode() {
                    if statusCode >= 200 && statusCode < 300 {
                        // Success response from server
                        if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                            completionClosure(jsonData)
                        }
                        else {
                            completionClosure(NSDictionary())
                        }
                    }
                    else if statusCode >= 400 && statusCode < 500 {
                        // Authondication error, We should Logout
                        if statusCode == 401 {
                            self.logoutAppforAuthondicationError()
                        }else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary{
                          if let errorvalues = jsonResult.allValues.first as? NSArray{
                            let errorkey = jsonResult.allKeys.first as? String ?? ""
                            let value = errorvalues[0]as? String ?? ""
                            completionClosure(["responseCode":statusCode , "Message" : "\(errorkey): \(value)"])
                          }
                        }
                        else {
                            // Authondication error, We should Logout
                            completionClosure(NSDictionary())
                        }
                    }
                    else if statusCode >= 500 {
                        // Server error, try later
                        completionClosure(NSDictionary())
                    }
                }
                else {
                    completionClosure(NSDictionary())
                }
            })
            postDataTask.resume()
            return
        }
        
        let imageData = image!.jpegData(compressionQuality: 0.3)
        request.httpBody = createBodyWithParameters(event.getvalue(), filePathKey: "img", imageDataKey: imageData, boundary: boundary)
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary  {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(["detail":"Internal error while creating Event, Please try after sometime"])
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                      // Authondication error, We should Logout
                      if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                      {
                        let respo : HTTPURLResponse = response as! HTTPURLResponse
                        let arr = jsonResult as NSArray
                        completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                      }
                      else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                      {
                        let respo : HTTPURLResponse = response as! HTTPURLResponse
                        let arr = jsonResult as NSDictionary
                        if let errorvalues = arr.allValues.first as? NSArray
                        {
                          let errorkey = arr.allKeys.first as? String ?? ""
                          let value = errorvalues[0]as? String ?? ""
                          completionClosure(["responseCode":respo.statusCode , "Message" : "\(errorkey): \(value)"])
                        }
                        else
                        {
                          completionClosure(NSDictionary())
                        }
                      }
                      else
                      {
                        completionClosure(NSDictionary())
                      }
                  }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(["detail":"Internal error while creating Event, Please try after sometime"])
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
        
    }
    //Edit event 200-reponse code
    
    func EditEvents(_ image : UIImage?, view : UIView, pk :NSNumber,  event : PostEditEvent, completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        Logger.log(log: "\(#function) : Edit Event Paramter \(event.getvalue())")
        
        var request = NSMutableURLRequest()
        request.timeoutInterval = 60
        let pass = pk.stringValue
        request = NSMutableURLRequest(url: URL(string: "\(UrlMain)events/\(pass)/")!)
        request.httpMethod = "PATCH"
        let boundary = generateBoundaryString()
        request.addValue("Token \(getUserToken())", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard image != nil else {
            request.httpBody = createBodyWithParameters(event.getvalue(), filePathKey: "img", imageDataKey: nil, boundary: boundary)

            let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                if let statusCode = response?.getStatusCode() {
                    if statusCode >= 200 && statusCode < 300 {
                        // Success response from server
                        if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                            completionClosure(jsonData)
                        }
                        else {
                            completionClosure(NSDictionary())
                        }
                    }
                    else if statusCode >= 400 && statusCode < 500 {
                      // Authondication error, We should Logout
                      if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                      }
                      else {
                        // Authondication error, We should Logout
                        if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                        {
                          let respo : HTTPURLResponse = response as! HTTPURLResponse
                          let arr = jsonResult as NSArray
                          completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                        }
                        else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                        {
                          let respo : HTTPURLResponse = response as! HTTPURLResponse
                          let arr = jsonResult as NSDictionary
                          if let errorvalues = arr.allValues.first as? NSArray
                          {
                            let errorkey = arr.allKeys.first as? String ?? ""
                            let value = errorvalues[0]as? String ?? ""
                            completionClosure(["responseCode":respo.statusCode , "Message" : "\(errorkey): \(value)"])
                          }
                          else
                          {
                            completionClosure(NSDictionary())
                          }
                        }
                        else
                        {
                          completionClosure(NSDictionary())
                        }
                      }
                    }
                    else if statusCode >= 500 {
                        // Server error, try later
                        completionClosure(NSDictionary())
                    }
                } else {
                    completionClosure(NSDictionary())
                }
            })
            postDataTask.resume()
            return
        }
        
        let imageData = image!.jpegData(compressionQuality: 0.3)
        request.httpBody = createBodyWithParameters(event.getvalue(), filePathKey: "img", imageDataKey: imageData, boundary: boundary)
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //List Notification
    func getNotify(completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        var request = NSMutableURLRequest()
        request.timeoutInterval = 60
        
        request = NSMutableURLRequest(url: NSURL(string: UrlMain+"notifications/")! as URL)
        
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //DElete Notification
    
    func deleteNotification(pk: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: NSURL(string: UrlMain+"notifications/"+pk+"/")! as URL)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    //mark_read
    
    func markReadNotification(pk: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: NSURL(string: UrlMain+"notifications/"+pk+"/"+"mark_read/" )! as URL)
        request.httpMethod = "PUT"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    
    // directory listing 200-reponse code
    func getDirectory(_ completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"directory_listings/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData:NSMutableArray = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSMutableArray {
                        completionClosure(["result" : jsonData])
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    
    // Event Delete 204 - reponse code
    
    func deleteEvent(_ event: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"events/"+event+"/")!)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    // Error logs  200 - response code
    func errorLogsSending(_ message: String ,completionClosure: (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: "http://flabulessdev.com/logging/ios/")!)
        request.httpMethod = "POST"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.timeoutInterval = 60
        let postString = message
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            }
        })
        task.resume()
    }
    
    
    ///v2/rewards/ 200 - response code
    func getRewards(_ steps: String ,nextUrl:String, completion: @escaping (_ rewards: RewardResponse?, _ error: Error?) -> Void) {
      var request: URLRequest!
      if nextUrl.isEmpty {
        request = URLRequest(url: URL(string: UrlMain+"rewards/?country=\(getregionofUser())")!)
      } else {
        request = URLRequest(url: URL(string: nextUrl)!)
      }

      request.httpMethod = "GET"
      request.timeoutInterval = 60

      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
      let token = getUserToken() as String
      request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
      let postDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let statusCode = response?.getStatusCode() {
          if statusCode >= 200 && statusCode < 300 {
            // Success response from server
            if let data = data {
              let decoder = JSONDecoder()
              decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
              do {
                let result = try decoder.decode(RewardResponse.self, from: data)
                completion(result, nil)
              } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
              }
            } else {
              completion(nil, APIError.UnexpectedResult)
            }
          } else if statusCode >= 400 && statusCode < 500 {
            // Authentication error, We should Logout
            if statusCode == 401 {
              self.logoutAppforAuthondicationError()
            } else {
              // Authentication error, We should Logout
              completion(nil, error ?? APIError.CannotFetch)
            }
          } else if statusCode >= 500 {
            // Server error, try later
            completion(nil, APIError.CannotFetch)
          }
        } else {
          completion(nil, APIError.UnexpectedResult)
        }
      }
      postDataTask.resume()
  }

  func getUpcomingRewards(_ completion: @escaping (_ rewards: [Reward]?, _ error: Error?) -> Void) {
    var request: URLRequest = URLRequest(url: URL(string: UrlMain + "rewards/upcoming/")!)

    request.httpMethod = "GET"
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")

    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            do {
              let result = try decoder.decode([Reward].self, from: data)
              completion(result, nil)
            } catch let error {
              print(error.localizedDescription)
              completion(nil, error)
            }
          } else {
            completion(nil, APIError.UnexpectedResult)
          }
        } else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            // Authondication error, We should Logout
            completion(nil, error ?? APIError.CannotFetch)
          }
        } else if statusCode >= 500 {
          // Server error, try later
          completion(nil, APIError.CannotFetch)
        }
      } else {
        completion(nil, APIError.UnexpectedResult)
      }
    }
    dataTask.resume()
  }

  func verifyPostalCode(_ zip: String, completion: @escaping (Result<PostalCodeResponse, Error>) -> Void) {
    var request: URLRequest = URLRequest(url: URL(string: UrlMain + "addresses/postal_address?zip=\(zip)")!)

    request.httpMethod = "GET"
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")

    let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    let postDataTask = urlSession.dataTask(with: request, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        guard let data = data else {
          completion(.failure(ApiError.dataFoundToBeNil))
          return
        }
        if statusCode >= 200 && statusCode < 300 {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let addressResponse = try decoder.decode(PostalCodeResponse.self, from: data)
            completion(.success(addressResponse))
          } catch let error {
            print(error.localizedDescription)
            completion(.failure(ApiError.serverError))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            do {
              let errorResponse = try JSONDecoder().decode(InvalidPostalCodeError.self, from: data)
              completion(.failure(APIError.Others(errorResponse.message)))
            } catch let error {
              print(error.localizedDescription)
              completion(.failure(ApiError.authenticationError))
            }
          }
        } else if statusCode >= 500 {
          completion(.failure(ApiError.serverError))
        }
      } else {
        completion(.failure(ApiError.badUrl))
      }
    })
    postDataTask.resume()
  }

  func postManualActivity(_ activityType: String, _ activityDate: ManualActivityData, completion: @escaping (Result<ManualActivityResponse, Error>) -> Void) {
    var request: URLRequest = URLRequest(url: URL(string: UrlMain + "activities/")!)

    request.httpMethod = "POST"
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")

    var params: [String: Any]
    params = [
      "activity_type": activityType,
      "source": "manual",
      "start_time": activityDate.date,
    ]
    if let rawActivity = activityDate.name {
      params["raw_activity_type"] = rawActivity
    }
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
    } catch let error {
      print(error)
      request.httpBody = nil
    }

    let urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    let postDataTask = urlSession.dataTask(with: request, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        guard let data = data else {
          completion(.failure(ApiError.dataFoundToBeNil))
          return
        }
        if statusCode >= 200 && statusCode < 300 {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
          do {
            let addressResponse = try decoder.decode(ManualActivityResponse.self, from: data)
            completion(.success(addressResponse))
          } catch let error {
            print(error.localizedDescription)
            completion(.failure(ApiError.serverError))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            do {
              let errorResponse = try JSONDecoder().decode(CommonError.self, from: data)
              completion(.failure(APIError.Others(errorResponse[0])))
            } catch _ {
              do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
                let val = try decoder.decode(Rest200ErrorResponse.self, from: data)
                completion(.failure(APIError.Others(val.nonFieldErrors?[0] ?? ApiError.authenticationError.rawValue)))
              } catch _ {
                completion(.failure(ApiError.authenticationError))
              }
            }
          }
        } else if statusCode >= 500 {
          completion(.failure(ApiError.serverError))
        }
      } else {
        completion(.failure(ApiError.badUrl))
      }
    })
    postDataTask.resume()
  }

  //get reward details
  func fetchRewardDetail(_ pkValue: String, _ completion: @escaping (_ result: Reward?, _ error: Error?) -> Void) {
    var request: URLRequest = URLRequest(url: URL(string: UrlMain + "rewards/\(pkValue)/?country=\(getregionofUser())")!)
    request.httpMethod = "GET"
    request.timeoutInterval = 60
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")

    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            do {
              let result = try decoder.decode(Reward.self, from: data)
              completion(result, nil)
            } catch let error {
              print(error.localizedDescription)
              completion(nil, error)
            }
          } else {
            completion(nil, APIError.Others("Reward is Expired"))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            // Authondication error, We should Logout
            completion(nil, error ?? APIError.CannotFetch)
          }
        } else if statusCode >= 500 {
          // Server error, try later
          completion(nil, APIError.CannotFetch)
        }
      } else {
        completion(nil, APIError.UnexpectedResult)
      }
    }
    dataTask.resume()
  }

  //fetch redeemption details
  func fetchRedeemptionDetails(_ pkValue: String, _ completion: @escaping (_ result: Redemption?, _ error: Error?) -> Void) {

    var request: URLRequest = URLRequest(url: URL(string: UrlMain + "redemption/\(pkValue)/")!)
    request.httpMethod = "GET"
    request.timeoutInterval = 60
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")

    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            do {
              let result = try decoder.decode(Redemption.self, from: data)
              completion(result, nil)
            } catch let error {
              print(error.localizedDescription)
              completion(nil, error)
            }
          } else {
            completion(nil, APIError.UnexpectedResult)
          }
        } else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            // Authondication error, We should Logout
            completion(nil, error ?? APIError.CannotFetch)
          }
        } else if statusCode >= 500 {
          // Server error, try later
          completion(nil, APIError.CannotFetch)
        }
      } else {
        completion(nil, APIError.UnexpectedResult)
      }
    }
    dataTask.resume()
  }


  func fetchRedemptions(_ nextUrl: String, _ completion: @escaping (_ result: RedemptionResponse?, _ error: Error?) -> Void) {
    var request: URLRequest!

    if nextUrl.isEmpty {
      request = URLRequest(url: URL(string: UrlMain + "redemption/")!)
    } else {
      request = URLRequest(url: URL(string: nextUrl)!)
    }

    request.httpMethod = "GET"
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    request.addValue("Token " + getUserToken(), forHTTPHeaderField: "Authorization")

    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            do {
              let result = try decoder.decode(RedemptionResponse.self, from: data)
              completion(result, nil)
            } catch let error {
              print(error.localizedDescription)
              completion(nil, error)
            }
          } else {
            completion(nil, APIError.UnexpectedResult)
          }
        } else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            // Authondication error, We should Logout
            completion(nil, error ?? APIError.CannotFetch)
          }
        } else if statusCode >= 500 {
          // Server error, try later
          completion(nil, APIError.CannotFetch)
        }
      } else {
        completion(nil, APIError.UnexpectedResult)
      }
    }
    dataTask.resume()
  }

    ///v2/feedback/answers
    func feedbackAnswers(_ answerDict: [[String: AnyObject]] ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"answers/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        let params = answerDict
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    

  func redeemRewards(_ rewardId: String, type: String, passcode: String, has_passcode: Bool, addressPk: Int?, completionClosure: @escaping (_ repos :NSDictionary) ->())  {

    let request = NSMutableURLRequest(url: URL(string: UrlMain+"rewards/redemption/")!)
    request.httpMethod = "POST"
    request.timeoutInterval = 60
    var params: NSDictionary
    if has_passcode {
      if let address = addressPk {
        params = [
          type: rewardId,
          "password": passcode,
          "delivery_address": address
          ] as NSDictionary
      } else {
        params = [type: rewardId, "password": passcode] as NSDictionary
      }
    } else{
      if let address = addressPk {
        params = [
          type: rewardId,
          "delivery_address": address
          ] as NSDictionary
      } else {
        params = [type: rewardId] as NSDictionary
      }
    }

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
    } catch _ as NSError {
      request.httpBody = nil
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = getUserToken() as String
    request.addValue("Token "+token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          if let data = data, let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
            completionClosure(jsonData)
          }
          else {
            completionClosure(NSDictionary())
          }
        }
        else if statusCode >= 400 && statusCode < 500 {
          // Authondication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          }
          else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary{
            if let errorvalues = jsonResult.allValues.first as? NSArray{
              let errorkey = jsonResult.allKeys.first as? String ?? ""
              let value = errorvalues[0]as? String ?? ""
              completionClosure(["responseCode":statusCode , "Message" : "\(errorkey): \(value)"])
            }
          }
          else {
            // Authondication error, We should Logout
            completionClosure(NSDictionary())
          }
        }
        else if statusCode >= 500 {
          // Server error, try later
          completionClosure(NSDictionary())
        }
      }
      else {
        completionClosure(NSDictionary())
      }
    })
    postDataTask.resume()
  }
    
    ///v2/event-checkin/
    func getEventsCheckIns(_ steps: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"event-checkin/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/event-checkin/ 201 - response code
    func postEventsCheckIns(_ event: String ,lat: String , lng: String , password : String ,force: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"event-checkin/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        var params = "event=\(event)&lat=\(lat)&lng=\(lng)"
        
        if !password.isEmpty {
            params = "event=\(event)&password=\(password)"
        }
        else if !force.isEmpty {
            params = "event=\(event)&lat=\(lat)&lng=\(lng)&force=\(force)"
        }
        
        let dataa = params.data(using: .utf8)
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = dataa
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/rsvp 201 - response
    func postrsvd(_ event: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"rsvp/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        let params = ["event":event] as NSDictionary
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                    {
                        let message = jsonResult[0] as! String
                        completionClosure(["detail":message])
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                    // Authondication error, We should Logout
                      // Authondication error, We should Logout
                      if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                      {
                        let respo : HTTPURLResponse = response as! HTTPURLResponse
                        let arr = jsonResult as NSArray
                        completionClosure(["responseCode":respo.statusCode , "detail" : arr[0]])
                      }
                      else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                      {
                        let respo : HTTPURLResponse = response as! HTTPURLResponse
                        let arr = jsonResult as NSDictionary
                        if let errorvalues = arr.allValues.first as? NSArray
                        {
                          let errorkey = arr.allKeys.first as? String ?? ""
                          let value = errorvalues[0]as? String ?? ""
                          completionClosure(["responseCode":respo.statusCode , "detail" : "\(errorkey): \(value)"])
                        }
                        else
                        {
                          completionClosure(NSDictionary())
                        }
                      }
                      else
                      {
                        completionClosure(NSDictionary())
                      }
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/rsvp/<<EventID>>/ 204-reponse code
    func postrsvdDelete(_ event: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"rsvp/"+event+"/")!)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/rsvp/
    func getrsvd(_ event: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"rsvp/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/category/ 200-response code
    func getCategories(_ event: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"category/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/facilities?category=<<CategoryID>>&alpha=1  200 - response code
    func getFacilities(_ categoryId: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"facilities/?category="+categoryId+"&alpha=1")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/locations/
    func postBookmark(_ location: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"locations/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        let params = ["location ":location] as NSDictionary
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/facility-checkin/ 200- response code
    func postFacilityCheckin(_ location: String, latt: String , long: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"facility-checkin/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        let params = "location=\(location)&lat=\(latt)&lng=\(long)" as String
        let dataa = params.data(using: .utf8)
        request.httpBody = dataa
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/facilities?category= 200-response code
    func getNearByFacilities(_ categoryId: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let lat =  "\(appdelegate.lattitude!)" as String
        let lng = "\(appdelegate.longitude!)" as String
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"facilities/?category="+categoryId+"&nearby=true&lat="+lat+"&lng="+lng)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/facilities?category= 200- response code
    func getFacilitiesByName(_ categoryId: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"facilities/?category="+categoryId+"&alpha=true")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/facilities?aplha=1&q=  200-reponse code
    func searchFacilitiesByName(_ searchtext: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let completeURL = UrlMain+"facilities/?aplha=1&search=\(searchtext)"
        let urlNew:String = completeURL.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let request = NSMutableURLRequest(url: URL(string: urlNew)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }

  func searchEvents(with key: String, choice: Int?, completion: @escaping (_ events: [RemoteEvent], _ error: Error?) -> Void) {
    var urlString = UrlMain + "events/?"
    if let choice = choice {
      urlString += "category_pk=\(choice)&"
    }
    urlString += "search=\(key)"
    guard let urlNew = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
      fatalError("'UrlString' url encoding failed.")
    }

    let request = NSMutableURLRequest(url: URL(string: urlNew)!)
    request.httpMethod = "GET"
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = "Token " + getUserToken()
    request.addValue(token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          // Success response from server
          guard let data = data else {
            completion([], InValidDataError())
            return
          }
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let events = try decoder.decode(EventsResponse.self, from: data)
            completion(events.results, nil)
          } catch let error {
            completion([], error)
          }
        } else if statusCode >= 400 && statusCode < 500 {
          // Authentication error, We should Logout
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            completion([], InValidDataError())
          }
        } else if statusCode >= 500 {
          // Server error, try later
          completion([], InValidDataError())
        }
      } else {
        completion([], InValidDataError())
      }
    })
    postDataTask.resume()
  }

  func firstTimeLogin(_ firstName: String, _ lastName: String, _ email: String, _ completion: @escaping (Result<FirstTimeLoginResponse, Error>) -> Void) {
    let urlNew: URL = URL(string: UrlMain + "users/change_default_email/")!
    var request: URLRequest = URLRequest(url: urlNew)

    request.httpMethod = "POST"
    request.timeoutInterval = 60
    let bodyData = "new_email=\(email)&first_name=\(firstName)&last_name=\(lastName)".data(using: String.Encoding.utf8)
    request.httpBody = bodyData
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = "Token " + getUserToken()
    request.addValue(token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
      if let statusCode = response?.getStatusCode() {
        guard let data = data else {
          completion(.failure(ApiError.dataFoundToBeNil))
          return
        }
        if statusCode >= 200 && statusCode < 300 {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let loginResponse = try decoder.decode(FirstTimeLoginResponse.self, from: data)
            completion(.success(loginResponse))
          } catch let error {
            print(error.localizedDescription)
            completion(.failure(ApiError.serverError))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            do  {
              let errorResponse = try JSONDecoder().decode(CommonError.self, from: data)
              completion(.failure(APIError.Others(errorResponse[0])))
            } catch {
              completion(.failure(ApiError.authenticationError))
            }
          }
        } else if statusCode >= 500 {
          completion(.failure(ApiError.serverError))
        }
      } else {
        completion(.failure(ApiError.badUrl))
      }
    })
    postDataTask.resume()
  }

  func getAddresses(completion: @escaping (Result<AddressResponse, ApiError>) -> Void) {
    let urlNew: URL = URL(string: UrlMain + "addresses/")!
    let request = NSMutableURLRequest(url: urlNew)
    request.httpMethod = "GET"
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = "Token " + getUserToken()
    request.addValue(token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        guard let data = data else {
          completion(.failure(.dataFoundToBeNil))
          return
        }
        if statusCode >= 200 && statusCode < 300 {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let addressResponse = try decoder.decode(AddressResponse.self, from: data)
            completion(.success(addressResponse))
          } catch let error {
            print(error.localizedDescription)
            completion(.failure(.serverError))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            completion(.failure(.authenticationError))
          }
        } else if statusCode >= 500 {
          completion(.failure(.serverError))
        }
      } else {
        completion(.failure(.badUrl))
      }
    })
    postDataTask.resume()
  }

  func postAddresses(_ address: Address, completion: @escaping (Result<Address, ApiError>) -> Void) {
    let urlNew: URL = URL(string: UrlMain + "addresses/")!
    let request = NSMutableURLRequest(url: urlNew)
    request.httpMethod = HTTPMethod.POST.rawValue
    request.timeoutInterval = 60

    var params: [String: Any]
    params = [
      "first_name": address.firstName,
      "last_name": address.lastName,
      "phone_number": address.phoneNumber,
      "address1": address.address1,
      "address2": address.address2,
      "city": address.city,
      "country": address.country,
      "postal_code": address.postalCode,
      "state_or_prefecture": address.stateOrPrefecture
    ]
    if let landmark = address.landmark {
      params["landmark"] = landmark
    }
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
    } catch _ as NSError {
      request.httpBody = nil
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = "Token " + getUserToken()
    request.addValue(token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        guard let data = data else {
          completion(.failure(.dataFoundToBeNil))
          return
        }
        if statusCode >= 200 && statusCode < 300 {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
          do {
            let addressResponse = try decoder.decode(Address.self, from: data)
            completion(.success(addressResponse))
          } catch let error {
            print(error.localizedDescription)
            completion(.failure(.serverError))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            completion(.failure(.authenticationError))
          }
        } else if statusCode >= 500 {
          completion(.failure(.serverError))
        }
      } else {
        completion(.failure(.badUrl))
      }
    })
    postDataTask.resume()
  }

  func deleteAddress(_ pk: Int, completion: @escaping (Result<String, ApiError>) -> Void) {
    let urlNew: URL = URL(string: UrlMain + "addresses/\(pk)/")!
    let request = NSMutableURLRequest(url: urlNew)
    request.httpMethod = HTTPMethod.DELETE.rawValue
    request.timeoutInterval = 60

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
    let token = "Token " + getUserToken()
    request.addValue(token, forHTTPHeaderField: "Authorization")

    let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          completion(.success(""))
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            completion(.failure(.authenticationError))
          }
        } else if statusCode >= 500 {
          completion(.failure(.serverError))
        }
      } else {
        completion(.failure(.badUrl))
      }
    })
    postDataTask.resume()
  }

    // v3
    func getLeaderBoardsv3(_ searchtext: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"leaderboard/")!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                      print(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //V3 Updated Design api Get User Profile
    
    func getUser(completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/current/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    // leaderboard top_ten
    func getleaderboardTop_ten(completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"leaderboard/top_ten/")!)
        request.timeoutInterval = 60
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func newGetLeaderboardTop_ten(completionClosure: @escaping (_ repos :NSDictionary?, _ error : String?) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"leaderboard/top_ten/")!)
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let unwrappedData = data,
                        let jsonData = ((try? JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary) as NSDictionary??){
                        completionClosure(jsonData, nil)
                    }else{
                        completionClosure(nil, "No Data")
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                      self.logoutAppforAuthondicationError()
                    } else {
                        // Authondication error, We should Logout
                        completionClosure(nil, "Error - \(statusCode)")
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(nil,"Error - \(statusCode)")
                }
            }
            else {
                completionClosure(nil, "Unexpected Response")
            }
        })
        postDataTask.resume()
    }
    
    // v3 other user profile
    func getotherUserprofile(_ pk : Int,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let pkstring = String(pk)
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/"+pkstring+"/")!)
        request.timeoutInterval = 60
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func updateEmailAddress(profile: Dictionary<String, AnyObject>, email: String, completionClosure: @escaping (_ repos :NSDictionary) ->()) {
        let pkValue = profile["pk"] as! Int
        let firstName = profile["first_name"] as! String
        let lastName = profile["last_name"] as! String
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/"+"\(pkValue)"+"/")!)
        request.timeoutInterval = 60
        request.httpMethod = "PUT"
        
        let bodyData = "email=\(email)&first_name=\(firstName)&last_name=\(lastName)".data(using: String.Encoding.utf8)
        request.httpBody = bodyData
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //
    func changePublicFlag(_ publicFlag : Bool,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/current/" )!)
        request.timeoutInterval = 60
        request.httpMethod = "PATCH"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        var params: NSDictionary
        
        params = ["publicly_visible":publicFlag]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    // Chnage public flag to private
    func chnagePublicFlag(_ image : UIImage?,publicFlag: Bool,fname : String, lname : String , address : String ,fitness : String,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"users/current/" )!)
        request.timeoutInterval = 60
        request.httpMethod = "PATCH"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        var params: NSDictionary
        if fname.isEmpty {
            params = ["publicly_visible":publicFlag]
        }
        else {
            params = ["first_name":fname,"last_name":lname,"address":address,"fitness_mantra":fitness]
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    // other graph
    
    func getothergraph(_ from_date: String , to_date: String,user : Int,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let userpk  = String(user)
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"history/")!)
        request.httpMethod = "POST"
        let params = "from_date=\(from_date)&to_date=\(to_date)&user=\(userpk)" as String
        let dataa = params.data(using: .utf8)
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.httpBody = dataa
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    } else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/leaderboard/ 200-response code
    func getLeaderBoards(_ searchtext: String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"leaderboard/")!)
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    } else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func newGetLeaderBoards(_ searchtext: String ,completionClosure: @escaping (_ repos :NSDictionary?, _ error: String?) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"leaderboard/")!)
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let unwrappedData = data,
                        let jsonData = ((try? JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary) as NSDictionary??){
                        completionClosure(jsonData, nil)
                    }else{
                        completionClosure(nil, "No Data")
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                  if statusCode == 401 {
                    self.logoutAppforAuthondicationError()
                  } else {
                    completionClosure(nil, "Error - \(statusCode)")
                  }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(nil, "Error - \(statusCode)")
                }
            }
            else {
                completionClosure(nil, "Unexpected Response")
            }
        })
        postDataTask.resume()
    }
    
    ///v2/history/ 200-response code
    func getHistory(_ from_date: String , to_date: String,completionClosure: @escaping (_ repos :NSDictionary?) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"history/")!)
        request.httpMethod = "POST"
        let params = "from_date=\(from_date)&to_date=\(to_date)" as String
        let dataa = params.data(using: .utf8)
        request.timeoutInterval = 120
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.httpBody = dataa
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //v2/user-stat/latest/ 200-response code
    func getLatestStatsInfo(_ completionClosure:@escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"user-stat/latest/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/user-stat/ 400-response code
    func postLatestStatsInfo(_ user : String , bmi : String , height : String, weight : String, muscle_mass_percentage : String, body_fat_percentage : String ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"user-stat/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let dateEnd: String = getFormattedDateFrom(Date(), dateFormat: "yyyy-MM-dd HH:mm:ssZ")
        let jsonDictionary = ["bmi" : bmi , "height" : height, "weight" : weight, "body_fat_percentage" : body_fat_percentage , "created" : dateEnd ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
        
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //v2/user-stat/ 200-response code
    func getAllStats(_ completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"user-stat/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    ///v2/steps-bulk/
    func saveStepsBulk(_ dictSteps: NSMutableDictionary ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"steps-bulk/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let params = dictSteps
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                //completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    // fake bulk Step app
    func sendBulkFakeSteps(_ dictSteps: NSMutableDictionary ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"steps-bulk/correct/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let params = dictSteps
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch _ as NSError {
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                //completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    // event filter 200-response code
    func getFilterOptios(_ completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"event-category-list" )!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    //Sync of StepTracker 200-response code
    func stepTrackerSync(_ completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"services/sync/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    // 200-response code
    func serviceConnectAppsGetKeys(_ completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"services/keys/")!)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    // 200 response code
    func serviceConnectApps(_ parameters:Dictionary<String,String>, completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        
        let method = parameters["method"]
        let appName = parameters["appName"]
        
        let request:NSMutableURLRequest!
        let token = getUserToken() as String
        
        if method == "DELETE" {
            request = NSMutableURLRequest(url: URL(string:UrlMain+"services/"+appName!+"/")!)
        }
        else {
            request = NSMutableURLRequest(url: URL(string:UrlMain+"services/")!)
        }
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.httpMethod = method!
        request.timeoutInterval = 60
        var params = String()
        
        if method == "POST" {
            if appName == "fitbit" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)&access_token_secret=\(parameters["refresh_token"]! as String)&encoded_user_id=\(parameters["user_id"]! as String)" as String
            }
            else if appName == "runkeeper" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
                
            else if appName == "jawbone" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
            else if appName == "misfit" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
            else if appName == "strava" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
            else
            {
                params = "name=\(appName! as String)" as String
            }
            
            let data = params.data(using: .utf8)
            request.httpBody = data
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func newServiceConnectApps(_ parameters:Dictionary<String,String>, completionClosure: @escaping (_ repos :NSDictionary?, _ error: String?) ->())  {
        
        let method = parameters["method"]
        let appName = parameters["appName"]
        
        let request:NSMutableURLRequest!
        let token = getUserToken() as String
        
        if method == "DELETE" {
            request = NSMutableURLRequest(url: URL(string:UrlMain+"services/"+appName!+"/")!)
        }
        else {
            request = NSMutableURLRequest(url: URL(string:UrlMain+"services/")!)
        }
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.httpMethod = method!
        request.timeoutInterval = 60
        var params = String()
        
        if method == "POST" {
            if appName == "fitbit" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)&access_token_secret=\(parameters["refresh_token"]! as String)&encoded_user_id=\(parameters["user_id"]! as String)" as String
            }
            else if appName == "runkeeper" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
                
            else if appName == "jawbone" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
            else if appName == "misfit" {
                params = "name=\(appName! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
            else if appName == "strava" {
              params = "name=\(appName! as String)&access_token_secret=\(parameters["refresh_token"]! as String)&expires_at=\(parameters["expires_at"]! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }else if appName == "polar" {
              params = "name=\(appName! as String)&encoded_user_id=\(parameters["x_user_id"]! as String)&expires_at=\(parameters["expires_in"]! as String)&access_token=\(parameters["access_token"]! as String)" as String
            }
            else
            {
                params = "name=\(appName! as String)" as String
            }
            
            let data = params.data(using: .utf8)
            request.httpBody = data
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            var errorString : String?
            if let unwrappedData = data{
                if let errorDictionary = ((try? JSONSerialization.jsonObject(with: unwrappedData, options: []) as? NSDictionary) as NSDictionary??){
                    errorString = (errorDictionary?.value(forKey: "non_field_errors") as? [String])?.first
                }
            }
            
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData, nil)
                    }
                    else {
                        completionClosure(NSDictionary(), nil)
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        completionClosure(nil, errorString ?? "Error - \(statusCode)")
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(nil, errorString ?? "Error - \(statusCode)")
                    }
                    
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(nil, errorString ?? "Error - \(statusCode)")
                }
            }
            else {
                completionClosure(nil, "Error - Unexpected response")
            }
        })
        postDataTask.resume()
    }
    
    //MARK:- Weight loss APIS
    func getWeightLossChallengeDescription(completionClosure: @escaping (_ repos :NSDictionary?) ->()) {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"challenges/challenges/")!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
        
    }
    
    func getWeightLossDashboardData(completionClosure: @escaping (_ repos :NSDictionary?) ->()) {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"challenges/dashboard/")!)
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func getWeightLossLeaderboardData(completionClosure: @escaping (_ repos :NSDictionary?) ->()) {
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"challenges/leaderboard/")!)
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func getWeightLossPerformanceData(completionClosure: @escaping (_ repos :NSDictionary?) ->()) {
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"challenges/progress/")!)
        request.httpMethod = "GET"
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func postWeightLossStatsCapture(height : String, weight : String, completionClosure: @escaping (_ repos :NSDictionary?) ->())  {
        
        let request = NSMutableURLRequest(url: URL(string: UrlMain+"challenges/capture/")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let jsonDictionary = ["height" : height, "weight" : weight]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
        
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func changePassword(email : String, password : String, confirmPassword : String, completionClosure: @escaping (_ repos :NSDictionary?) ->())  {
        
        let request: NSMutableURLRequest!
        var jsonDictionary = ["old_password" : password, "password" : confirmPassword]
        if !email.isEmpty {
            jsonDictionary["email"] = email
            request  = NSMutableURLRequest(url: URL(string: UrlMain+"users/current/update_password/")!)
        }
        else {
            request  = NSMutableURLRequest(url: URL(string: UrlMain+"users/current/change_password/")!)
        }
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
        
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(["message":"success"])
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        if let jsonData: NSArray = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray {
                            completionClosure(["message":jsonData.firstObject as Any])
                        }
                        else {
                            completionClosure(["message":"Unable to update password, Please try after some time."])
                        }
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(["message":"Internal server error, Please try after some time."])
                }
            }
            else {
                completionClosure(["message":"Internal server error, Please try after some time."])
            }
        })
        postDataTask.resume()
    }
    //delete photo
    func deletePhoto(eventPk : String,photoPK: String, completionClosure: @escaping (_ repos :NSDictionary?) ->())  {
        if Reachability()!.connection == Reachability.Connection.none {
            completionClosure(NSDictionary())
            ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
            return
        }
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"event_galleries/\(eventPk)/delete_image/?image=\(photoPK)" )!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(["message":"success"])
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                        {
                            let respo : HTTPURLResponse = response as! HTTPURLResponse
                            let arr = jsonResult as NSArray
                            completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                        }
                        else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                        {
                            let respo : HTTPURLResponse = response as! HTTPURLResponse
                            let arr = jsonResult as NSDictionary
                            if let errorvalues = arr.allValues.first as? NSArray
                            {
                                let errorkey = arr.allKeys.first as? String ?? ""
                                let value = errorvalues[0]as? String ?? ""
                                completionClosure(["responseCode":respo.statusCode , "Message" : "\(errorkey): \(value)"])
                            }
                            else
                            {
                                completionClosure(NSDictionary())
                            }
                        }
                        else
                        {
                            completionClosure(NSDictionary())
                        }
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(["message":"Internal server error, Please try after some time."])
                }
            }
            else {
                completionClosure(["message":"Internal server error, Please try after some time."])
            }
        })
        postDataTask.resume()
    }
    //change caption
    func changeCaption(caption : String,photoPK: String, completionClosure: @escaping (_ repos :NSDictionary?) ->())  {
        if Reachability()!.connection == Reachability.Connection.none {
            completionClosure(NSDictionary())
            ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
            return
        }
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"event_photos/\(photoPK)/" )!)
        request.httpMethod = "PUT"
        request.timeoutInterval = 60
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        let jsonDictionary = ["caption" : caption]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let token = getUserToken() as String
        request.addValue("Token "+token, forHTTPHeaderField: "Authorization")
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest , completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(["message":"success"])
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        if let jsonData: NSArray = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray {
                            completionClosure(["message":jsonData.firstObject as Any])
                        }
                        else {
                            completionClosure(["message":"Unable to update password, Please try after some time."])
                        }
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(["message":"Internal server error, Please try after some time."])
                }
            }
            else {
                completionClosure(["message":"Internal server error, Please try after some time."])
            }
        })
        postDataTask.resume()
    }
    
    func addPhotoService(_ eventPk : String, image : UIImage? , dictUserDetails: [String: String] ,completionClosure: @escaping (_ repos :NSDictionary) ->())  {
        if Reachability()!.connection == Reachability.Connection.none {
            completionClosure(NSDictionary())
            ErrorDisplayer.showError(errorTitle: "No Network!", errorMsg: "Please enable the internet and try agian.")
            return
        }
        
        let request = NSMutableURLRequest(url: URL(string:UrlMain+"event_galleries/\(eventPk)/upload/" )!)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        let boundary = generateBoundaryString()
        
        let token = getUserToken() as String
        request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
        request.addValue(getIphoneSelectedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image!.jpegData(compressionQuality: 0.3)
        request.httpBody = createBodyWithParameters(dictUserDetails, filePathKey: "image", imageDataKey: imageData, boundary: boundary)
        request.timeoutInterval = 60
        
        let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let statusCode = response?.getStatusCode() {
                if statusCode >= 200 && statusCode < 300 {
                    // Success response from server
                    if let jsonData: NSDictionary = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary {
                        completionClosure(jsonData)
                    }
                    else {
                        completionClosure(NSDictionary())
                    }
                }
                else if statusCode >= 400 && statusCode < 500 {
                    // Authondication error, We should Logout
                    if statusCode == 401 {
                        self.logoutAppforAuthondicationError()
                    }
                    else {
                        // Authondication error, We should Logout
                        if let jsonResult: NSMutableArray  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSMutableArray
                        {
                            let respo : HTTPURLResponse = response as! HTTPURLResponse
                            let arr = jsonResult as NSArray
                            completionClosure(["responseCode":respo.statusCode , "Message" : arr[0]])
                        }
                        else if let jsonResult: NSDictionary  = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                        {
                            let respo : HTTPURLResponse = response as! HTTPURLResponse
                            let arr = jsonResult as NSDictionary
                            if let errorvalues = arr.allValues.first as? NSArray
                            {
                                let errorkey = arr.allKeys.first as? String ?? ""
                                let value = errorvalues[0]as? String ?? ""
                                completionClosure(["responseCode":respo.statusCode , "Message" : "\(errorkey): \(value)"])
                            }
                            else
                            {
                                completionClosure(NSDictionary())
                            }
                        }
                        else
                        {
                            completionClosure(NSDictionary())
                        }
                    }
                }
                else if statusCode >= 500 {
                    // Server error, try later
                    completionClosure(NSDictionary())
                }
            }
            else {
                completionClosure(NSDictionary())
            }
        })
        postDataTask.resume()
    }
    
    func logoutAppforAuthondicationError () {
        DispatchQueue.main.async {
            saveUserToken(accessToken: "")
            setActivityTracker("")
            set_trackernamefromapi("")
            set_helplinePannel(false)
            if let navigationController = appdelegate.window?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            } else {
                appdelegate.window?
                  .rootViewController?
                  .navigationController?
                  .popToRootViewController(animated: true)
            }
        }
    }

  func uploadManualSteps(with request: ManualStepSyncRequest, _ completion: @escaping (Result<ManualStepSyncResponse, Error>) -> Void) {
    let boundary = generateBoundaryString()
    var urlRequest = URLRequest(url: URL(string: UrlMain + "services/upload_screenshot/")!)
    urlRequest.timeoutInterval = 60
    urlRequest.httpMethod = "POST"
    urlRequest.addValue(
      getIphoneSelectedLanguage(),
      forHTTPHeaderField: "Accept-Language"
    )
    urlRequest.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    urlRequest.addValue(
      "Token " + getUserToken(),
      forHTTPHeaderField: "Authorization"
    )
    urlRequest.httpBody = createBodyWithParameters(
      ["service_name" : request.serviceName],
      filePathKey: "screenshot",
      imageDataKey: request.screenshot,
      boundary: boundary
    )

    let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, apiError) in
      if let statusCode = response?.getStatusCode() {
        if statusCode >= 200 && statusCode < 300 {
          if let validData = data {
            do {
              let decoder = JSONDecoder()
              decoder.keyDecodingStrategy = .convertFromSnakeCase
              let responseObject: ManualStepSyncResponse = try decoder
                .decode(ManualStepSyncResponse.self, from: validData)
              completion(.success(responseObject))
            } catch let error {
              completion(.failure(error))
            }
          } else {
            completion(.failure(ApiError.dataFoundToBeNil))
          }
        } else if statusCode >= 400 && statusCode < 500 {
          if statusCode == 401 {
            self.logoutAppforAuthondicationError()
          } else {
            completion(.failure(apiError ?? ApiError.serverError))
          }
        } else if statusCode >= 500 {
          completion(.failure(ApiError.serverError))
        }
      } else {
        completion(.failure(ApiError.badUrl))
      }
    }

    dataTask.resume()
  }
}

extension ServiceParserMethods: URLSessionTaskDelegate {
  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    let accessToken = "Token \(getUserToken())"
    let networkHeaders = [ "Content-Type": "application/json", "Authorization": accessToken]

    guard let url = request.url else { return }

    var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = networkHeaders

    completionHandler(request)
  }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
