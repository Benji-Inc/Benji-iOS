//
//  ChannelCollectionViewManager+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/20/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROFutures

extension ChannelCollectionViewManager {

    @discardableResult
    func updateConsumers(with consumer: Avatar, for message: Messageable) -> Future<Void> {
        //create system message copy of current message
        let messageCopy = SystemMessage(with: message)
        messageCopy.udpateConsumers(with: consumer)

        runMain {
            //update the current message with the copy
            self.updateItem(with: messageCopy, completion: nil)
        }

        //call update on the actual message and update on callback
        return message.udpateConsumers(with: consumer)
    }

    func setAllMessagesToRead() -> Future<[Void]> {
        let promises: [Future<Void>] = MessageSupplier.shared.unreadMessages.map { (message) -> Future<Void> in
            return self.updateConsumers(with: User.current()!, for: message)
        }

        return waitForAll(futures: promises)
    }
}