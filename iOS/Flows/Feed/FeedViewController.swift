//
//  HomeStackViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

protocol FeedViewControllerDelegate: AnyObject {
    func feedView(_ controller: FeedViewController, didSelect item: PostType)
}

class FeedViewController: ViewController {

    lazy var manager: FeedManager = {
        let manager = FeedManager(with: self, delegate: self)
        return manager
    }()

    weak var delegate: FeedViewControllerDelegate?

    enum State {
        case noRitual
        case lessThanAnHourAway
        case feedAvailable
        case lessThanHourAfter
        case moreThanHourAfter
    }

    @Published var state: State = .noRitual

    private let countDownView = CountDownView()
    private let messageLabel = Label(font: .medium)
    private let reloadButton = Button()
    lazy var indicatorView = FeedIndicatorView(with: self)

    var message: Localized? {
        didSet {
            guard let text = self.message else { return }
            self.messageLabel.setText(text)
        }
    }

    private var currentTriggerDate: Date? {
        return UserDefaults.standard.value(forKey: Ritual.currentKey) as? Date
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.messageLabel)
        self.view.addSubview(self.reloadButton)
        self.messageLabel.alpha = 0
        self.messageLabel.textAlignment = .center
        self.reloadButton.alpha = 0
        self.view.addSubview(self.countDownView)
        self.view.addSubview(self.indicatorView)
        self.indicatorView.alpha = 0

        self.countDownView.didExpire = { [unowned self] in
            self.addItems()
        }

        self.reloadButton.set(style: .normal(color: .purple, text: "Reload"))
        self.reloadButton.didSelect { [unowned self] in
            self.reloadFeed()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.manager.posts.isEmpty {
            self.loadFeed()
        }
    }

    private func loadFeed() {
        if let ritual = User.current()?.ritual {
            ritual.retrieveDataIfNeeded()
                .mainSink(receivedResult: { (result) in
                    switch result {
                    case .success(let r):
                        self.subscribeToRitualUpdates()
                        self.determineMessage(with: r)
                    case .error(_):
                        self.state = .noRitual
                        self.addFirstItems()
                    }
                }).store(in: &self.cancellables)
        } else {
            self.state = .noRitual
            self.addFirstItems()
        }
    }

    private func subscribeToRitualUpdates() {
        User.current()?.ritual?.subscribe()
            .mainSink(receiveValue: { (event) in
                switch event {
                case .created(let r), .updated(let r):
                    self.determineMessage(with: r)
                case .deleted(_):
                    self.addFirstItems()
                default:
                    break
                }
            }).store(in: &self.cancellables)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.messageLabel.setSize(withWidth: self.view.width * 0.8)
        self.messageLabel.centerOnXAndY()

        self.reloadButton.size = CGSize(width: 140, height: 40)
        self.reloadButton.top = self.messageLabel.bottom + 40
        self.reloadButton.centerOnX()

        self.countDownView.size = CGSize(width: 200, height: 60)
        self.countDownView.centerY = self.view.halfHeight * 0.8
        self.countDownView.centerOnX()

        self.indicatorView.size = CGSize(width: self.view.width - 20, height: 2)
        self.indicatorView.pinToSafeArea(.top, padding: 0)
        self.indicatorView.centerOnX()
    }

    func showReload() {
        self.messageLabel.setText("You are all caught up!\nSee you tomorrow 🤗")
        self.view.bringSubviewToFront(self.reloadButton)
        self.view.layoutNow()
        UIView.animate(withDuration: Theme.animationDuration, delay: Theme.animationDuration, options: .curveEaseInOut, animations: {
            self.reloadButton.alpha = 1
            self.messageLabel.alpha = 1
            self.indicatorView.alpha = 0
        }, completion: { _ in })
    }

    private func reloadFeed() {
        self.view.sendSubviewToBack(self.reloadButton)
        UIView.animate(withDuration: Theme.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.reloadButton.alpha = 0
            self.messageLabel.alpha = 0
            self.indicatorView.alpha = 1
            self.indicatorView.resetAllIndicators()
        }, completion: { completed in
            self.manager.showFirst()
        })
    }

    private func determineMessage(with ritual: Ritual) {
        guard let triggerDate = ritual.date,
            self.currentTriggerDate != triggerDate,
            let anHourAfter = triggerDate.add(component: .hour, amount: 1),
            let anHourUntil = triggerDate.subtract(component: .hour, amount: 1) else { return }

        //Set the current trigger date so we dont reload for duplicates
        UserDefaults.standard.set(triggerDate, forKey: Ritual.currentKey)

        let now = Date()
        
        //If date is 1 hour or less away, show countDown
        if now.isBetween(anHourUntil, and: triggerDate) {
            self.state = .lessThanAnHourAway
            self.countDownView.startTimer(with: triggerDate)
            self.showCountDown()

            //If date is less than an hour ahead of current date, show feed
        } else if now.isBetween(triggerDate, and: anHourAfter) {
            self.state = .feedAvailable
            self.addItems()

        //If date is 1 hour or more away, show "see you at (date)"
        } else if now.isBetween(Date().beginningOfDay, and: anHourUntil) {
            self.state = .lessThanHourAfter
            let dateString = Date.hourMinuteTimeOfDay.string(from: triggerDate)
            self.message = "Take a break! ☕️\nSee you at \(dateString)"
            self.showMessage()
        } else {
            self.state = .moreThanHourAfter
            let dateString = Date.hourMinuteTimeOfDay.string(from: triggerDate)
            self.message = "See you tomorrow at \n\(dateString)"
            self.showMessage()
        }

        self.view.layoutNow()
    }

    private func showCountDown() {
        self.messageLabel.alpha = 0
        self.countDownView.alpha = 0
        self.countDownView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: Theme.animationDuration, animations: {
            self.countDownView.transform = .identity
            self.countDownView.alpha = 1
        }, completion: nil)
    }

    private func showMessage() {
        self.countDownView.alpha = 0
        self.messageLabel.alpha = 0
        self.view.layoutNow()
        self.messageLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: Theme.animationDuration, animations: {
            self.messageLabel.transform = .identity
            self.messageLabel.alpha = 1
        }, completion: nil)
    }

    func showFeed() {
        UIView.animate(withDuration: Theme.animationDuration, delay: 0, options: [], animations: {
            self.countDownView.alpha = 0
            self.countDownView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.indicatorView.alpha = 1
            self.messageLabel.alpha = 0
            self.reloadButton.alpha = 0
        }, completion: nil)
    }
}
