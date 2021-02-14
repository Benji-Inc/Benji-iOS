//
//  FeedCell.swift
//  Benji
//
//  Created by Benji Dodgson on 7/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class FeedView: View {

    private let container = View()

    //lazy var introView = PostIntroViewController()
    lazy var ritualView = FeedRitualView()
    //lazy var inviteView = PostChannelInviteViewController()
    lazy var unreadView = FeedUnreadView()
    //lazy var needInvitesView = PostReservationViewController()
    lazy var notificationsView = FeedNotificationPermissionsView()
    //lazy var connectionView = PostConnectionViewController()
    //lazy var meditationView = PostMeditationViewController()
    lazy var newChannelView = FeedNewChannelView()

    var didSelect: CompletionOptional = nil
    var didSkip: CompletionOptional = nil

    private(set) var feedType: PostType

    init(with type: PostType) {
        self.feedType = type
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeSubviews() {
        super.initializeSubviews()
        self.addSubview(self.container)

        self.container.didSelect { [unowned self] in
            self.didSkip?()
        }

        switch self.feedType {
        case .timeSaved(let count):
            break 
//            self.container.addSubview(self.introView)
//            self.introView.set(count: count)
        case .system(_):
            break
        case .unreadMessages(let channel, let count):
            self.container.addSubview(self.unreadView)
            self.unreadView.configure(with: channel, count: count)
            self.unreadView.didSelect = { [unowned self] in
                self.didSelect?()
            }
        case .channelInvite(let channel):
            break 
//            self.container.addSubview(self.inviteView)
//            self.inviteView.configure(with: channel)
//            self.inviteView.didComplete = { [unowned self] in
//                self.didSelect?()
//            }
        case .inviteAsk(let reservation):
            break 
//            self.container.addSubview(self.needInvitesView)
//            self.needInvitesView.reservation = reservation
//            self.needInvitesView.button.didSelect { [unowned self] in
//                self.didSelect?()
//            }
        case .rountine:
            self.container.addSubview(self.ritualView)
            self.ritualView.button.didSelect { [unowned self] in
                self.didSelect?()
            }
        case .notificationPermissions:
            self.container.addSubview(self.notificationsView)
            self.notificationsView.didGivePermission = { [unowned self] in
                self.didSelect?()
            }
        case .connectionRequest(let connection):
            break
//            self.container.addSubview(self.connectionView)
//            self.connectionView.configure(connection: connection)
//            self.connectionView.didComplete = { [unowned self] in
//                self.didSelect?()
//            }
        case .meditation:
            break 
//            self.container.addSubview(self.meditationView)
//            self.meditationView.button.didSelect { [unowned self] in
//                self.didSelect?()
//            }
        case .newChannel(let channel):
            self.container.addSubview(self.newChannelView)
            self.newChannelView.configure(with: channel)
            self.newChannelView.didSelect = { [unowned self] in
                self.didSelect?()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let margin = Theme.contentOffset * 2
        self.container.size = CGSize(width: self.width - margin, height: self.height - margin)
        self.container.centerOnXAndY()

        if let first = self.container.subviews.first {
            first.frame = self.container.bounds
        }
    }
}
