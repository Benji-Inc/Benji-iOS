//
//  MainCoordinator+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/16/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension MainCoordinator: UserNotificationManagerDelegate {
    func userNotificationManager(willHandle deeplink: DeepLinkable) {
        self.deepLink = deeplink
        self.handle(deeplink: deeplink)
    }
}

extension MainCoordinator: LaunchManagerDelegate {

    func launchManager(_ manager: LaunchManager, didReceive activity: LaunchActivity) {
        self.furthestChild.handle(launchActivity: activity)
    }

    func launchManager(_ manager: LaunchManager, didFinishWith status: LaunchStatus) {
        #if !APPCLIP
        // Code you don't want to use in your App Clip.
        self.handle(result: status)
        #else
        // Code your App Clip may access.
        self.handleAppClip(result: status)
        #endif

        self.subscribeToUserUpdates()
    }

    func subscribeToUserUpdates() {
        guard let user = User.current() else { return }
        UserSubscriber(for: user).$update.mainSink { (update) in
            guard let update = update, update.status == .deleted else { return }
            self.showLogOutAlert()
        }.store(in: &self.cancellables)
    }

    #if APPCLIP
    func handleAppClip(result: LaunchStatus) {
        switch result {
        case .success(let object, _):
            self.deepLink = object
            runMain {
                self.runOnboardingFlow()
            }
        case .failed(_):
            break
        }
    }
    #endif
}
