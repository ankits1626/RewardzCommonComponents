//
//  MockUserListProvider.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 06/12/20.
//

import Foundation

struct TaggedUserFetchResult {
    var error : String?
    var users : [ASTaggedUser]?
}

//class MockUserListProvider {
//    var dummyUsers : [TaggedUser] = [
//        TaggedUser(displayName: "Ankit", userId: 0, profileImage: nil, emailId: "ankit@rewardz.com"),
//        TaggedUser(displayName: "Amit", userId: 1, profileImage: nil, emailId: "amit@rewardz.com"),
//        TaggedUser(displayName: "Anni", userId: 2, profileImage: nil, emailId: "anni@rewardz.com"),
//        TaggedUser(displayName: "Anand", userId: 3, profileImage: nil, emailId: "anand@rewardz.com"),
//        TaggedUser(displayName: "Anamika", userId: 4, profileImage: nil, emailId: "anamika@rewardz.com"),
//        TaggedUser(displayName: "Brijesh", userId: 4, profileImage: nil, emailId: "Brijesh@rewardz.com"),
//        TaggedUser(displayName: "Brian", userId: 4, profileImage: nil, emailId: "Brian@rewardz.com"),
//        
//    ]
//    
//    func fetchTaggedUser(searchKey: String, completion : @escaping ((TaggedUserFetchResult) -> Void)) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            completion(TaggedUserFetchResult(error: nil, users: self.dummyUsers.filter({ (user) -> Bool in
//                user.displayName .contains(searchKey) || user.emailId.contains(searchKey)
//            })))
//        }
//    }
//}

