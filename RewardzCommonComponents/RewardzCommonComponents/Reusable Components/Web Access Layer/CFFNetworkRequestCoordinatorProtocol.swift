//
//  CFFNetworkRequestCoordinatorProtocol.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import Foundation

public protocol CFFNetworkRequestCoordinatorProtocol : class {
    func getBaseUrlProvider() -> BaseURLProviderProtocol
    func getLogoutHandler() -> LogoutResponseHandler
    func getTokenProvider() -> TokenProviderProtocol
}
