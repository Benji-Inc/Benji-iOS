//
//  FeedViewController+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension FeedViewController {

    func subscribeToUpdates() {

        ChannelManager.shared.clientSyncUpdate.producer.on(value:  { [weak self] (update) in
            guard let `self` = self, let clientUpdate = update else { return }
            
            switch clientUpdate {
            case .completed:
                self.addItems()
            default:
                break
            }
        })
        .start()
    }

    func addItems() {
        FeedSupplier.shared.getItems()
            .withResultToast()
            .observeValue(with: { (items) in
                runMain {
                    self.view.layoutNow()
                    self.manager.set(items: items)
                    self.showFeed()
                }
            })
    }

    func addFirstItems() {
        FeedSupplier.shared.getFirstItems()
        .withResultToast()
        .observeValue(with: { (items) in
            runMain {
                self.manager.set(items: items)
                self.showFeed()
            }
        })
    }
}
