//
//  AttachementCell.swift
//  Benji
//
//  Created by Benji Dodgson on 8/29/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Photos
import Combine

class AttachmentCell: CollectionViewManagerCell, ManageableCell {
    typealias ItemType = Attachment

    private let imageView = DisplayableImageView()
    private let selectedView = View()
    var currentItem: Attachment?

    override func initializeSubviews() {
        self.contentView.addSubview(self.imageView)
        self.imageView.imageView.contentMode = .scaleToFill
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 5

        self.contentView.addSubview(self.selectedView)
        self.selectedView.backgroundColor = Color.lightPurple.color.withAlphaComponent(0.5)
        self.selectedView.alpha = 0
        self.selectedView.layer.cornerRadius = 5
    }

    func configure(with item: Attachment) {

        AttachmentsManager.shared.getImage(for: item, size: self.size)
            .mainSink { (image, _) in
                self.imageView.displayable = image 
            }.store(in: &self.cancellables)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.expandToSuperviewSize()
        self.selectedView.frame = self.imageView.frame
    }

    override func update(isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.selectedView.alpha = isSelected ? 1.0 : 0.0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.displayable = nil
    }
}
