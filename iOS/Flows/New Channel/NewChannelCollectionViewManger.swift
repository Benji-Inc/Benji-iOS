//
//  NewChannelCollectionViewManger.swift
//  Ours
//
//  Created by Benji Dodgson on 2/17/21.
//  Copyright © 2021 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Combine

class NewChannelCollectionViewManger: CollectionViewManager<NewChannelCollectionViewManger.SectionType> {

    enum SectionType: Int, ManagerSectionType {
        case users
    }

    private var cancellables = Set<AnyCancellable>()
    private var connections: [Connection] = []

    private let userConfig = ManageableCellRegistration<UserCell>().cellProvider

    override func initialize() {
        super.initialize()

        self.allowMultipleSelection = true 

        GetAllConnections().makeRequest(andUpdate: [], viewsToIgnore: [])
            .mainSink { result in
                switch result {
                case .success(let connections):
                    self.connections = connections.filter { (connection) -> Bool in
                        return !connection.nonMeUser.isNil
                    }
                    self.loadSnapshot()
                case .error(_):
                    break
                }
            }.store(in: &self.cancellables)
    }

    override func getItems(for section: SectionType) -> [AnyHashable] {
        return self.connections
    }

    override func getCell(for section: SectionType, indexPath: IndexPath, item: AnyHashable?) -> CollectionViewManagerCell? {
        return self.collectionView.dequeueManageableCell(using: self.userConfig, for: indexPath, item: item as? Connection)
    }
}
