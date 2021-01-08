//
//  AppDelegate.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let rootNavController = RootNavigationController()
        self.initializeKeyWindow(with: rootNavController)
        self.initializeMainCoordinator(with: rootNavController, withOptions: launchOptions)
        #if !APPCLIP
        // Code you don't want to use in your App Clip.
        UserDefaults.standard.set(nil, forKey: Ritual.currentKey)
        #endif
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UserNotificationManager.shared.clearNotificationCenter()
        #if !APPCLIP
        guard !ChatClientManager.shared.isConnected, let _ = User.current()?.objectId else { return }

//        GetChatToken()
//            .makeRequest(andUpdate: [], viewsToIgnore: [])
//        
//            .mainsi
//            .observeValue { (token) in
//                if ChatClientManager.shared.client.isNil {
//                    ChatClientManager.shared.initialize(token: token)
//                } else {
//                    ChatClientManager.shared.update(token: token)
//                }
//        }
        #endif
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return LaunchManager.shared.continueUser(activity: userActivity)
    }

    #if !APPCLIP
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserNotificationManager.shared.registerPush(from: deviceToken)
    }

    func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard application.applicationState == .active || application.applicationState == .inactive else {
            completionHandler(.noData)
            return
        }

        if UserNotificationManager.shared.handle(userInfo: userInfo) {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    #endif
}

