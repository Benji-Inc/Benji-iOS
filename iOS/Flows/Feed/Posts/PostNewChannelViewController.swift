//
//  FeedNewChannelView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/20/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import TMROLocalization
import Combine

class PostNewChannelViewController: PostViewController {

    override func initializeViews() {
        super.initializeViews()

        self.button.set(style: .normal(color: .purple, text: "OPEN"))
    }

    override func configurePost() {
        guard let channel = self.post.channel else { return }
        self.configure(with: channel)
    }

    override func didTapButton() {
        self.didSelectPost?()
    }

    func configure(with channel: TCHChannel) {
        
        channel.getAuthorAsUser()
            .mainSink(receiveValue: { (user) in
                self.avatarView.set(avatar: user)
                let message = LocalizedString(id: "", arguments: [user.givenName], default: "Congrats! 🎉 You can now chat with @(name)!")
                self.textView.set(localizedText: message)
                self.container.layoutNow()
            }).store(in: &self.cancellables)
    }
}
