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
    case Document
}

public protocol MediaItemProtocol {
    func getMediaType() -> FeedMediaItemType
    func getCoverImageUrl() -> String?
    func getRemoteId() -> Int
    func getGiphy() -> String?
    func getImagePK() -> Int?
    func getFileName() -> String?
    func getFileUrl() -> URL?
}

public extension MediaItemProtocol{
    func getFileUrl() -> URL?{
        return nil
    }
    
    func getFileName() -> String?{
        return nil
    }
}

