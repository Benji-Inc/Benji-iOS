//
//  ProfileViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TwilioChatClient

struct ProfileItem: ProfileDisplayable {
    var avatar: Avatar? = nil
    var title: String
    var text: String
    var hasDetail: Bool = false
}

protocol ProfileViewControllerDelegate: class {
    func profileView(_ controller: ProfileViewController, didSelectRoutineFor user: PFUser)
}

class ProfileViewController: ViewController {

    private let user: User
    let topBar = View()
    lazy var collectionView = ProfileCollectionView()
    lazy var manager = ProfileCollectionViewManager(with: self.collectionView)
    weak var delegate: ProfileViewControllerDelegate?

    init(with user: User) {
        self.user = user
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.collectionView
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .background2)

        self.collectionView.delegate = self.manager
        self.collectionView.dataSource = self.manager

        self.manager.didSelectItemAt = { [unowned self] indexPath in
            self.delegate?.profileView(self, didSelectRoutineFor: self.user)
        }

        self.view.addSubview(self.topBar)
        self.topBar.set(backgroundColor: .background3)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.createItems()
    }

    private func createItems() {
        var items: [ProfileDisplayable] = []

        let avatarItem = ProfileItem(avatar: self.user,
                                     title: String(),
                                     text: String(),
                                     hasDetail: false)
        items.append(avatarItem)

        let handleItem = ProfileItem(avatar: nil,
                                     title: "Handle",
                                     text: String(optional: self.user.handle),
                                     hasDetail: false)
        items.append(handleItem)

        RoutineManager.shared.getRoutineNotifications().observe { (result) in
            runMain {
                switch result {
                case .success(let notificationRequests):
                    guard let trigger = notificationRequests.first?.trigger
                        as? UNCalendarNotificationTrigger else {
                            self.setNoRoutineItem(for: items)
                            return
                    }

                    self.setRoutineItem(with: trigger.dateComponents, for: items)
                case .failure(_):
                    break
                }
            }
        }
    }

    private func setNoRoutineItem(for items: [ProfileDisplayable]) {
        var items = items
        let routineItem = ProfileItem(avatar: nil,
                                      title: "Routine",
                                      text: "NO ROUTINE SET",
                                      hasDetail: true)
        items.append(routineItem)

        self.manager.items = items
        self.collectionView.reloadData()
    }

    private func setRoutineItem(with components: DateComponents, for items: [ProfileDisplayable]) {
        var items = items

        let calendar = Calendar.current

        if let date = calendar.date(from: components) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let string = formatter.string(from: date)
            let routineItem = ProfileItem(avatar: nil,
                                          title: "Routine",
                                          text: string.uppercased(),
                                          hasDetail: true)
            items.append(routineItem)

            self.manager.items = items
            self.collectionView.reloadData()

        } else {
            self.setNoRoutineItem(for: items)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.topBar.size = CGSize(width: 30, height: 4)
        self.topBar.top = 8
        self.topBar.centerOnX()
        self.topBar.layer.cornerRadius = 2
    }
}
