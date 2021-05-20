//
//  HorizontalScrollAdapterProtocol.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import Foundation

public protocol HorizontalListIdentifierProtocol {
  static func getIdentifier(_ identifier : Any) -> Self?
}


public protocol HorizontalScrollAdapterProtocol {
    var datasource: HorizontalScrollAdapterDatasource? {set get}
    var delegate: HorizontalScrollAdapterDelegate? {set get}
    var identifier: HorizontalListIdentifierProtocol {set get}
    init(
        _ identifier : HorizontalListIdentifierProtocol,
        datasource : HorizontalScrollAdapterDatasource,
        delegate: HorizontalScrollAdapterDelegate?,
        networkRequestCoordinator : CFFNetworkRequestCoordinatorProtocol,
        mediaFetcher : CFFMediaCoordinatorProtocol
    )
    func getSelectedIndex() -> Int
}

public protocol HorizontalScrollAdapterDatasource : class {
    func getNumberOfItems(_ adapterIdentifier :HorizontalListIdentifierProtocol) -> Int
    func getItem(_ adapterIdentifier: HorizontalListIdentifierProtocol, index: Int) -> Any?
    func getSelectedIndex(_ adapterIdentifier: HorizontalListIdentifierProtocol, index: Int) -> Int
    func deleteItem(_ adapterIdentifier :HorizontalListIdentifierProtocol, index: Int)
}

public protocol HorizontalScrollAdapterDelegate : class {
    func selectedItem(_ adapterIdentifier: HorizontalListIdentifierProtocol?, index: Int)
}

public protocol HorizontalFilterScrollAdapterDelegate : class {
    func selectedItem(_ adapterIdentifier: HorizontalListIdentifierProtocol, index: Int, selectedItems : [String])
}

public protocol HorizontalFilterScrollAdapterProtocol {
    var datasource: HorizontalScrollAdapterDatasource? {set get}
    var delegate: HorizontalFilterScrollAdapterDelegate? {set get}
    var identifier: HorizontalListIdentifierProtocol {set get}
    init(_ identifier : HorizontalListIdentifierProtocol, datasource : HorizontalScrollAdapterDatasource, delegate: HorizontalFilterScrollAdapterDelegate?,selectedItems : [String])
    func getSelectedIndex() -> Int
}
