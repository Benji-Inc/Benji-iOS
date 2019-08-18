//
//  ChannelViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift

class ChannelViewController: ViewController, ScrolledModalControllerPresentable, KeyboardObservable {

    var topMargin: CGFloat {
        guard let topInset = UIWindow.topWindow()?.safeAreaInsets.top else { return 0 }
        return topInset + 60
    }

    var scrollView: UIScrollView? {
        return self.channelCollectionVC.collectionView
    }

    var scrollingEnabled: Bool = true
    var didUpdateHeight: ((CGFloat, TimeInterval) -> ())?

    let channelType: ChannelType

    lazy var channelCollectionVC = ChannelCollectionViewController()

    private let messageInputView = MessageInputView()
    private(set) var bottomGradientView = GradientView()

    var oldTextViewHeight: CGFloat = 48
    let bottomOffset: CGFloat = 16

    init(channelType: ChannelType) {
        self.channelType = channelType
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(withObject object: DeepLinkable) {
        fatalError("init(withObject:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.registerKeyboardEvents()
        self.view.set(backgroundColor: .background3)

        self.addChild(viewController: self.channelCollectionVC)
        self.view.addSubview(self.bottomGradientView)

        self.view.addSubview(self.messageInputView)
        self.messageInputView.textView.growingDelegate = self

        self.messageInputView.contextButton.onTap { [unowned self] (tap) in
            guard let text = self.messageInputView.textView.text, !text.isEmpty else { return }
            // self.sendSystem(message: text)
            self.send(message: text)
        }

        self.channelCollectionVC.collectionView.onDoubleTap { [unowned self] (doubleTap) in
            if self.messageInputView.textView.isFirstResponder {
                self.messageInputView.textView.resignFirstResponder()
            }
        }

        self.loadMessages(for: self.channelType)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.channelCollectionVC.view.frame = self.view.bounds

        self.messageInputView.size = CGSize(width: self.view.width - 32, height: self.messageInputView.textView.currentHeight)
        self.messageInputView.centerOnX()
        self.messageInputView.bottom = self.view.height - self.view.safeAreaInsets.bottom - self.bottomOffset

        let gradientHeight = self.view.height - self.messageInputView.top
        self.bottomGradientView.size = CGSize(width: self.view.width, height: gradientHeight)
        self.bottomGradientView.bottom = self.view.height
        self.bottomGradientView.centerOnX()
    }

    func loadMessages(for type: ChannelType) {
        self.channelCollectionVC.loadMessages(for: type)
    }

    func sendSystem(message: String) {
        let systemMessage = SystemMessage(avatar: Lorem.avatar(),
                                          context: Lorem.context(),
                                          body: message,
                                          id: String(Lorem.randomString()),
                                          isFromCurrentUser: true,
                                          timeStampAsDate: Date())
        self.channelCollectionVC.channelDataSource.append(item: .system(systemMessage))
        self.reset()
    }

    func send(message: String) {
        guard let channel = ChannelManager.shared.selectedChannel else { return }

        ChannelManager.shared.sendMessage(to: channel, with: message)
        self.reset()
    }

    private func reset() {
        self.channelCollectionVC.collectionView.scrollToBottom()
        self.messageInputView.textView.text = String()
    }

    func handleKeyboard(state: KeyboardState, with animationDuration: TimeInterval) {

        switch state {
        case .willHide(let height), .willShow(let height):
            UIView.animate(withDuration: animationDuration, animations: {
                self.messageInputView.bottom = self.view.height - height - self.bottomOffset
                self.bottomGradientView.bottom = self.messageInputView.bottom
                self.channelCollectionVC.collectionView.height = self.view.height - height
                self.channelCollectionVC.collectionView.collectionViewLayout.invalidateLayout()
            }) { (completed) in
                if completed {
                    self.channelCollectionVC.collectionView.scrollToBottom()
                }
            }
        default:
            break 
        }
    }
}

extension ChannelViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.messageInputView.textView.height = height
            self.oldTextViewHeight = height
        }
    }
}
