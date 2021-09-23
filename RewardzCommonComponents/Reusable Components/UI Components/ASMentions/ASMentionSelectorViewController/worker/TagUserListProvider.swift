//
//  TagUserListProvider.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 15/12/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias TagUserFetchResultHandler = (APICallResult<TaggedUserFetchResult>) -> Void

class TagUserListProvider  {
    typealias ResultType = TaggedUserFetchResult
    var commonAPICall : CommonAPICall<TagUserListDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func fetchUserList(_ searchKey: String, shouldSearchOnlyDepartment: Bool, completionHandler: @escaping TagUserFetchResultHandler){
        self.commonAPICall = CommonAPICall(
            apiRequestProvider: TagUserListRequestGenerator(
                searchKey,
                shouldSearchOnlyDepartment: shouldSearchOnlyDepartment,
                networkRequestCoordinator: networkRequestCoordinator
            ),
            dataParser: TagUserListDataParser(),
            logouthandler: networkRequestCoordinator.getLogoutHandler()
        )
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class TagUserListRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var searchKey : String
    private var shouldSearchOnlyDepartment : Bool
    
    init(_ searchKey: String, shouldSearchOnlyDepartment: Bool, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
         self.searchKey = searchKey
        self.shouldSearchOnlyDepartment = shouldSearchOnlyDepartment
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let q = shouldSearchOnlyDepartment ?   "department" : "organization"
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/search_users/?term=\(searchKey)&q=\(q)"),
                    method: .GET,
                    httpBodyDict: nil
                )
                return req
            }
            return nil
        }
    }
}

class TagUserListDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [[String : Any]]
    typealias ResultType = TaggedUserFetchResult
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var taggedUsers : [ASTaggedUser] = [ASTaggedUser]()
        for aRawUser in fetchedData {
            taggedUsers.append(ASTaggedUser(aRawUser))
        }
        return APICallResult.Success(
            result: TaggedUserFetchResult(error: nil, users:taggedUsers)
        )
    }
}
