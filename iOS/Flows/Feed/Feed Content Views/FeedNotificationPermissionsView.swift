//
//  FeedNotificationPermissionsView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/24/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Combine

class FeedNotificationPermissionsView: View {

    let textView = FeedTextView()
    let button = Button()
    var didGivePermission: CompletionOptional = nil
    private var cancellables = Set<AnyCancellable>()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.button)
        self.textView.set(localizedText: "Notifications are only sent for important messages and daily ritual remiders. Nothing else.")
        self.button.set(style: .rounded(color: .purple, text: "OK"))
        self.button.didSelect { [unowned self] in
            self.handleNotificationPermissions()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.textView.setSize(withWidth: self.width)
        self.textView.bottom = self.centerY - 10
        self.textView.centerOnX()

        self.button.setSize(with: self.width)
        self.button.centerOnX()
        self.button.bottom = self.height - Theme.contentOffset
    }

    private func handleNotificationPermissions() {
        self.button.handleEvent(status: .loading)
        UserNotificationManager.shared.register(application: UIApplication.shared)
            .mainSink { (granted) in
                self.button.handleEvent(status: .complete)
                if granted {
                    self.didGivePermission?()
                } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }.store(in: &self.cancellables)
    }
}

