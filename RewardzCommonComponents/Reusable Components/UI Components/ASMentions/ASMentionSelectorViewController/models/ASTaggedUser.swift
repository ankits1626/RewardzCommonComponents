//
//  ASTaggedUser.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 19/12/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct ASTaggedUser {
    var firstName : String
    var lastName : String
    var displayName : String{
        get{
            if firstName.isEmpty && lastName.isEmpty{
                return "\(userId)"
            }else{
                return "\(firstName) \(lastName)"
            }
        }
    }
    var userId : Int
    var profileImage : String?
    var emailId: String
    var department: String
    
    init(_ rawUser: [String : Any]) {
        firstName = rawUser["first_name"] as? String ?? ""
        lastName = rawUser["last_name"] as? String ?? ""
        userId = rawUser["pk"] as? Int ?? -1
        emailId = rawUser["email"] as? String ?? ""
        profileImage = rawUser["profile_img"] as? String
        department = ((rawUser["departments"] as? [[String : Any]])?.first)?["name"] as? String ?? ""
    }
    
    func getTagMarkup() -> String {
        return "<tag><display_name>\(displayName.isEmpty ? "\(userId)" : displayName)</display_name><pk>\(userId)</pk><email_id>\(emailId)</email_id></tag>"
    }
}
