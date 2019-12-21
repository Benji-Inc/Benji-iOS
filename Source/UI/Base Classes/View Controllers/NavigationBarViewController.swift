//
//  NavigationBarViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 10/20/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class NavigationBarViewController: ViewController {

    private let titleLabel = MediumLabel()
    private let descriptionLabel = XSmallLabel()
    /// Place all views under the lineView 
    private(set) var lineView = View()
    let scrollView = UIScrollView()

    override func loadView() {
        self.view = self.scrollView
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.titleLabel)
        self.titleLabel.set(text: self.getTitle(), alignment: .center)
        self.view.addSubview(self.descriptionLabel)
        self.descriptionLabel.set(text: self.getDescription(),
                                  color: .white,
                                  alignment: .center,
                                  stringCasing: .unchanged)
        self.view.addSubview(self.lineView)
        self.lineView.set(backgroundColor: .background3)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.titleLabel.setSize(withWidth: 200)
        self.titleLabel.top = Theme.contentOffset
        self.titleLabel.centerOnX()

        self.descriptionLabel.setSize(withWidth: self.view.width * 0.6)
        self.descriptionLabel.top = self.titleLabel.bottom + 20
        self.descriptionLabel.centerOnX()

        self.lineView.size = CGSize(width: self.view.width - (Theme.contentOffset * 2), height: 2)
        self.lineView.top = self.descriptionLabel.bottom + 20
        self.lineView.centerOnX()
    }

    // MARK: PUBLIC

    func getTitle() -> Localized {
        return LocalizedString.empty
    }

    func getDescription() -> Localized {
        return LocalizedString.empty
    }
}
