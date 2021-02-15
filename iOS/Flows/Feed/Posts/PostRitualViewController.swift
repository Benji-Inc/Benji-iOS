//
//  FeedRitualView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Combine

class PostRitualViewController: PostViewController {

    override func initializeViews() {
        super.initializeViews()

        User.current()?.ritual?.subscribe()
            .mainSink(receiveValue: { (event) in
                print(event)
            }).store(in: &self.cancellables)

        self.textView.set(localizedText: "Set a time each day to check your Daily Feed.")
        self.button.set(style: .rounded(color: .purple, text: "SET"))
    }

    override func didTapButton() {
        self.didFinish?()
    }
}
