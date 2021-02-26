//
//  AppDelegate+Initialization.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {

    func initializeKeyWindow(with rootViewController: UIViewController) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }

    #if !NOTIFICATION
    func initializeMainCoordinator(with rootNavController: RootNavigationController,
                                   withOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        let router = Router(navController: rootNavController)
        self.mainCoordinator = MainCoordinator(router: router, deepLink: nil)
        self.mainCoordinator?.launchOptions = launchOptions
        self.mainCoordinator?.start()
    }
    #endif
}
