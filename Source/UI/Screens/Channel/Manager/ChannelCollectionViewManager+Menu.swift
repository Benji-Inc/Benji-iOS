//
//  ChannelCollectionViewManager+Menu.swift
//  Benji
//
//  Created by Benji Dodgson on 11/16/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

extension ChannelCollectionViewManager {

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {

        guard let messageType = self.item(at: indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? MessageCell else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return MessagePreviewViewController(with: messageType,
                                                cellWidth: cell.contentView.width)
        }, actionProvider: { suggestedActions in

            return self.makeContextMenu(for: messageType, at: indexPath)
        })
    }

    private func makeContextMenu(for message: Messageable, at indexPath: IndexPath) -> UIMenu {

        // Create a UIAction for sharing
        let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            //let items = [localized(message.text)]
            //let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            //self.present(ac, animated: true)
        }

        let editMessage = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
            // Show rename UI
        }

        // Here we specify the "destructive" attribute to show that it’s destructive in nature
        let neverMind = UIAction(title: "Never Mind", image: UIImage(systemName: "nosign")) { action in

        }

        let confirm = UIAction(title: "Confirm", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            self.delete(item: message, in: indexPath.section)
        }

        let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [confirm, neverMind])

        // Create and return a UIMenu with the share action
        return UIMenu(title: "Menu", children: [share, editMessage, deleteMenu])
    }
}

private class MessagePreviewViewController: ViewController {

    let message: Messageable
    let messageTextView = MessageTextView()
    let cellWidth: CGFloat
    let bubbleView = View()

    init(with message: Messageable,
         cellWidth: CGFloat) {

        self.message = message
        self.cellWidth = cellWidth

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.bubbleView
    }

    override func initializeViews() {
        super.initializeViews()

        self.messageTextView.set(text: self.message.text)

        let backgroundColor: Color = self.message.isFromCurrentUser ? .lightPurple : .purple
        self.bubbleView.set(backgroundColor: backgroundColor)
        self.view.addSubview(self.messageTextView)
        self.messageTextView.setSize(withWidth: self.cellWidth - 20)

        self.preferredContentSize.height = self.messageTextView.height + 20
        self.preferredContentSize.width = self.cellWidth
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.messageTextView.centerOnXAndY()
    }
}