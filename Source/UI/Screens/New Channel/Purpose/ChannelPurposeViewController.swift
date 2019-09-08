//
//  ChannelPurposeViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 9/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ChannelPurposeViewController: ViewController {

    let textFieldTitleLabel = RegularSemiBoldLabel()
    let textField = PurposeTitleTextField()
    let textFieldDescriptionLabel = XSmallLabel()

    let textViewTitleLabel = RegularSemiBoldLabel()
    let textView = PurposeDescriptionTextView()
    let textViewDescriptionLabel = XSmallLabel()

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.textFieldTitleLabel)
        self.textFieldTitleLabel.set(text: "Channel Name")
        self.view.addSubview(self.textField)
        self.view.addSubview(self.textFieldDescriptionLabel)
        self.textFieldDescriptionLabel.set(text: "Names must be lowercase, without spaces or periods, and can't be longer than 80 characters.")
        self.view.addSubview(self.textViewTitleLabel)
        self.view.addSubview(self.textViewDescriptionLabel)
        self.textViewDescriptionLabel.set(text: "Purpose (Optional)")

        self.textField.onTextChanged = { [unowned self] in
            self.handleTextChange()
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.textField.size = CGSize(width: self.view.width, height: 40)
        self.textField.left = 0
        self.textField.bottom = self.view.height - 10

        self.textField.setBottomBorder(color: .white)
    }

    private func handleTextChange() {
        guard let text = self.textField.text else { return }

    }
}
