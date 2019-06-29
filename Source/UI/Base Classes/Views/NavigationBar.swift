//
//  NavigationBar.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class NavigationBar: View {

    static let margin: CGFloat = 14

    private let titleLabel = Label()

    let leftContainer = UIView()
    private(set) var leftItem: UIView?
    private var leftTapHandler: (() -> Void)?

    let rightContainer = UIView()
    private(set) var rightItem: UIView?
    private var rightTapHandler: (() -> Void)?

    override func initializeViews() {
        super.initializeViews()

        self.set(backgroundColor: .clear)

        self.addSubview(self.titleLabel)
        self.addSubview(self.leftContainer)
        
        self.leftContainer.onTap { [unowned self] (tapRecognizer) in
            guard self.leftItem != nil else { return }
            self.leftTapHandler?()
        }

        self.addSubview(self.rightContainer)
        self.rightContainer.onTap { [unowned self] (tapRecognizer) in
            guard self.rightItem != nil else { return }
            self.rightTapHandler?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.leftContainer.left = NavigationBar.margin
        self.leftContainer.size = CGSize(width: 50, height: self.height)
        self.leftContainer.centerOnY()

        self.leftItem?.frame = self.leftContainer.bounds
        self.leftItem?.contentMode = .center

        self.rightContainer.size = CGSize(width: 50, height: self.height)
        self.rightContainer.right = self.width - NavigationBar.margin
        self.rightContainer.centerOnY()

        self.rightItem?.frame = self.rightContainer.bounds
        self.rightItem?.contentMode = .center

        if self.leftItem == nil && self.rightItem == nil {
            // If there are no left or right items, give more space for the title
            self.titleLabel.width = self.width - 2 * NavigationBar.margin
        } else {
            // Otherwise, fill the space between the item containers with the title label
            self.titleLabel.width = self.rightContainer.left - self.leftContainer.right
        }
        self.titleLabel.height = self.height
        self.titleLabel.centerOnXAndY()
    }

    func setTitle(_ localizedTitle: Localized, stringCasing: StringCasing = .capitalized) {
        self.titleLabel.set(attributed: AttributedString(localizedTitle,
                                                         size: 24,
                                                         color: .white),
                            alignment: .center,
                            stringCasing: stringCasing)
    }

    func setLeft(_ item: UIView?, tapHandler: @escaping () -> Void) {
        self.leftItem?.removeFromSuperview()

        self.leftItem = item
        if let leftItem = self.leftItem {
            self.leftContainer.addSubview(leftItem)
        }

        self.leftTapHandler = tapHandler

        self.setNeedsLayout()
    }

    func setRight(_ item: UIView, tapHandler: @escaping () -> Void) {
        self.rightItem?.removeFromSuperview()

        self.rightItem = item
        if let rightItem = self.rightItem {
            self.rightContainer.addSubview(rightItem)
        }

        self.rightTapHandler = tapHandler

        self.setNeedsLayout()
    }
}