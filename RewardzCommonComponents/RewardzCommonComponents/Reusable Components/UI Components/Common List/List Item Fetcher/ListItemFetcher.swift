//
//  ListItemFetcher.swift
//  SKOR
//
//  Created by Rewardz on 27/12/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//

import Foundation

public class ListItemParser<T : ListItemProtocol> : DataParserProtocol {
    public typealias ExpectedRawDataType = NSDictionary
    public typealias ResultType = [T]
    public func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Failure(error: APIError.Others("Implement a class"))
    }
}

public class ListItemFetcher<T : ListItemProtocol> {
    var commonAPICall : CommonAPICall<ListItemParser<T>>?
    var requestGenerator : APIRequestGeneratorProtocol
    var parser : ListItemParser<T>
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    public init(requestGenerator : APIRequestGeneratorProtocol, parser : ListItemParser<T>, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.requestGenerator = requestGenerator
        self.parser = parser
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    public func fetchListItem(completionHandler: @escaping ((APICallResult<[T]>) -> Void)) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: requestGenerator,
                dataParser: parser,
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        self.commonAPICall?.callAPI(completionHandler: { (result) in
            completionHandler(result)
        })
    }
}

