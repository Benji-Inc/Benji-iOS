//
//  NewChannelViewController.swift
//  Ours
//
//  Created by Benji Dodgson on 2/17/21.
//  Copyright © 2021 Benjamin Dodgson. All rights reserved.
//

import Foundation

class NewChannelViewController: CollectionViewController<NewChannelCollectionViewManger.SectionType, NewChannelCollectionViewManger> {

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var didCreateChannel: CompletionOptional = nil

    private let createButton = Button()

    override func getCollectionView() -> CollectionView {
        return NewChannelCollectionView()
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.insertSubview(self.blurView, belowSubview: self.collectionViewManager.collectionView)

        self.collectionViewManager.$onSelectedItem.mainSink { _ in
            self.createButton.isEnabled = self.collectionViewManager.selectedItems.count > 0
        }.store(in: &self.cancellables)

        self.view.insertSubview(self.createButton, aboveSubview: self.collectionViewManager.collectionView)
        self.createButton.set(style: .normal(color: .purple, text: "Create"))
        self.createButton.didSelect { [unowned self] in
            self.createChannel()
        }

        self.createButton.transform = CGAffineTransform.init(translationX: 0, y: 100)

        self.collectionViewManager.didLoadSnapshot = { [unowned self] in
            UIView.animate(withDuration: Theme.animationDuration) {
                self.createButton.transform = .identity
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.blurView.expandToSuperviewSize()

        self.createButton.setSize(with: self.view.width)
        self.createButton.pinToSafeArea(.bottom, padding: 0)
        self.createButton.centerOnX()
    }

    func createChannel() {

        let members: [String] = self.collectionViewManager.selectedItems.compactMap { item in
            guard let connection = item as? Connection else { return nil }
            return connection.nonMeUser?.objectId
        }

        ChannelSupplier.shared.createChannel(friendlyName: "", members: members, setActive: true)
        self.didCreateChannel?()
    }
}
