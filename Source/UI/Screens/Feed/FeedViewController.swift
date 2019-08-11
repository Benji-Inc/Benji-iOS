//
//  HomeStackViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Koloda

class FeedViewController: ViewController {


    let animateInProperty = UIViewPropertyAnimator(duration: Theme.animationDuration,
                                                   curve: .easeInOut,
                                                   animations: nil)

    let animateOutProperty = UIViewPropertyAnimator(duration: Theme.animationDuration,
                                                   curve: .easeInOut,
                                                   animations: nil)

    private let kolodaView = KolodaView()

    lazy var manager: FeedCollectionViewManager = {
        let manager = FeedCollectionViewManager(with: self.kolodaView)
        return manager
    }()

    override func loadView() {
        self.view = self.kolodaView
    }

    override func initializeViews() {
        super.initializeViews()

        self.kolodaView.dataSource = self.manager
        self.kolodaView.delegate = self.manager

        self.subscribeToUpdates()
    }

    func animateIn(completion: @escaping CompletionHandler) {
        let animator = UIViewPropertyAnimator(duration: Theme.animationDuration,
                                              curve: .easeInOut) {
                                                self.view.transform = CGAffineTransform.identity
                                                self.view.alpha = 1
                                                self.view.layoutNow()
        }
        animator.addCompletion { (position) in
            if position == .end {
                completion(true, nil)
            }
        }

        animator.startAnimation()
    }

    func animateOut(completion: @escaping CompletionHandler) {
        let animator = UIViewPropertyAnimator(duration: Theme.animationDuration,
                                              curve: .easeInOut) {
                                                self.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                                self.view.alpha = 0
                                                self.view.layoutNow()
        }
        animator.addCompletion { (position) in
            if position == .end {
                completion(true, nil)
            }
        }

        animator.startAnimation()
    }
}
