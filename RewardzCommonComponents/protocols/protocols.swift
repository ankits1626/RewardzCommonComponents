//
//  protocols.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 31/03/21.
//

import Foundation

public enum FeedMediaItemType{
    case Image
    case Video
}

public protocol MediaItemProtocol {
    func getMediaType() -> FeedMediaItemType
    func getCoverImageUrl() -> String?
    func getRemoteId() -> Int
    func getGiphy() -> String?
    func getImagePK() -> Int?
}

