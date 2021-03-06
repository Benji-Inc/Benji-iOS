//
//  InputTextView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/2/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ExpandingTextView: TextView {

    private var initialPlaceholder: String?

    override func initialize() {
        super.initialize()

        self.translatesAutoresizingMaskIntoConstraints = false
        self.textContainer.heightTracksTextView = true
        self.isScrollEnabled = false
        self.keyboardType = .twitter
        self.tintColor = Color.white.color

        self.textContainerInset.left = 10
        self.textContainerInset.right = 10
        self.textContainerInset.top = 14
        self.textContainerInset.bottom = 12

        self.set(backgroundColor: .clear)
    }

    func setPlaceholder(for avatars: [Avatar]) {
        var placeholderText = "Message "

        for (index, avatar) in avatars.enumerated() {
            if index < avatars.count - 1 {
                placeholderText.append(String("\(avatar.givenName), "))
            } else if index == avatars.count - 1 && avatars.count > 1 {
                placeholderText.append(String("and \(avatar.givenName)"))
            } else {
                placeholderText.append(avatar.givenName)
            }
        }

        self.initialPlaceholder = placeholderText
        self.set(placeholder: placeholderText, color: .lightPurple)
    }

    func setPlaceholder(for kind: MessageKind) {
        switch kind {
        case .text(_):
            if let placeholder = self.initialPlaceholder {
                self.set(placeholder: placeholder, color: .lightPurple)
            }
        case .photo(_, _), .video(_, _):
            self.set(placeholder: "Add comment", color: .lightPurple)
        default:
            break
        }
    }
}
