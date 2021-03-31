//
//  UnauthorizedHandler.swift
//  SKOR
//
//  Created by Rewardz on 09/09/17.
//  Copyright © 2017 Nikhil. All rights reserved.
//

import Foundation

protocol UnAuthorizedResponseProtocol {
    func checkAndHandleIfFailureIsDueToUnAuthorizedResponse(statusCode: Int?)
}
extension UnAuthorizedResponseProtocol{
    func checkAndHandleIfFailureIsDueToUnAuthorizedResponse(statusCode: Int?){
        if let unwrappedStatusCode = statusCode{
            if unwrappedStatusCode == 401{
                print("here")
            }
        }
    }
}
