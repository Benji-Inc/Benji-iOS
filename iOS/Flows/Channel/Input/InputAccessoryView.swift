//
//  MessageInputAccessoryView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/2/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Lottie
import TMROLocalization
import Combine

typealias InputAccessoryDelegates = MessageInputAccessoryViewDelegate

protocol MessageInputAccessoryViewDelegate: AnyObject {
    func inputAccessory(_ view: InputAccessoryView, didConfirm sendable: Sendable)
}

class InputAccessoryView: View, ActiveChannelAccessor {

    static let preferredHeight: CGFloat = 54.0
    private static let maxHeight: CGFloat = 200.0

    var previewAnimator: UIViewPropertyAnimator?
    var previewView: PreviewMessageView?
    var interactiveStartingPoint: CGPoint?

    var currentContext: MessageContext = .casual {
        didSet {
            self.borderColor = self.currentContext.color.color.cgColor
        }
    }
    var editableMessage: Messageable?
    var currentMessageKind: MessageKind = .text(String())

    var alertAnimator: UIViewPropertyAnimator?
    var selectionFeedback = UIImpactFeedbackGenerator(style: .rigid)
    var borderColor: CGColor? {
        didSet {
            self.inputContainerView.layer.borderColor = self.borderColor ?? self.currentContext.color.color.cgColor
        }
    }

    let inputContainerView = View()
    let attachmentView = AttachmentView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    lazy var textView = InputTextView(with: self)
    let alertProgressView = AlertProgressView()
    let animationView = AnimationView(name: "loading")
    let plusAnimationView = AnimationView(name: "plusToX")
    let overlayButton = UIButton()
    var cancellables = Set<AnyCancellable>()

    private(set)var inputLeadingContstaint: NSLayoutConstraint?
    private(set) var attachmentHeightAnchor: NSLayoutConstraint?

    unowned let delegate: InputAccessoryDelegates

    init(with delegate: InputAccessoryDelegates) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: InputAccessoryView.preferredHeight)
    }

    override var intrinsicContentSize: CGSize {
        var newSize = self.bounds.size

        if self.textView.bounds.size.height > 0.0 {
            newSize.height = self.textView.bounds.size.height + 20.0
        }

        if let constraint = self.attachmentHeightAnchor, constraint.constant > 0 {
            newSize.height += self.attachmentView.height + 10
        }

        if newSize.height < InputAccessoryView.preferredHeight || newSize.height > 120.0 {
            newSize.height = InputAccessoryView.preferredHeight
        }

        if newSize.height > InputAccessoryView.maxHeight {
            newSize.height = InputAccessoryView.maxHeight
        }

        return newSize
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .clear)

        self.currentContext = .casual

        self.addSubview(self.plusAnimationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .autoReverse

        self.addSubview(self.inputContainerView)
        self.inputContainerView.set(backgroundColor: .clear)

        self.inputContainerView.addSubview(self.blurView)

        self.inputContainerView.addSubview(self.animationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop

        self.inputContainerView.addSubview(self.alertProgressView)
        self.alertProgressView.set(backgroundColor: .red)
        self.alertProgressView.size = .zero

        self.inputContainerView.addSubview(self.textView)
        self.inputContainerView.addSubview(self.attachmentView)
        self.inputContainerView.addSubview(self.overlayButton)

        self.inputContainerView.layer.masksToBounds = true
        self.inputContainerView.layer.borderWidth = Theme.borderWidth
        self.inputContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.inputContainerView.layer.cornerRadius = Theme.cornerRadius

        self.setupConstraints()
        self.setupGestures()
        self.setupHandlers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.blurView.expandToSuperviewSize()
        self.overlayButton.expandToSuperviewSize()
        self.alertProgressView.height = self.inputContainerView.height

        self.animationView.size = CGSize(width: 18, height: 18)
        self.animationView.match(.right, to: .right, of: self.inputContainerView, offset: Theme.contentOffset)
        self.animationView.centerOnY()
    }

    // MARK: SETUP

    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false

        let guide = self.layoutMarginsGuide

        self.plusAnimationView.translatesAutoresizingMaskIntoConstraints = false
        self.plusAnimationView.bottomAnchor.constraint(equalTo: self.textView.bottomAnchor).isActive = true
        self.plusAnimationView.heightAnchor.constraint(equalToConstant: 43).isActive = true
        self.plusAnimationView.widthAnchor.constraint(equalToConstant: 43).isActive = true
        self.plusAnimationView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true

        self.inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.inputContainerView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        self.inputContainerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10).isActive = true
        self.inputLeadingContstaint = self.inputContainerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 53)
        self.inputLeadingContstaint?.isActive = true
        self.inputContainerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true

        self.attachmentView.leadingAnchor.constraint(equalTo: self.inputContainerView.leadingAnchor).isActive = true
        self.attachmentView.trailingAnchor.constraint(equalTo: self.inputContainerView.trailingAnchor).isActive = true
        self.attachmentView.topAnchor.constraint(equalTo: self.inputContainerView.topAnchor).isActive = true
        self.attachmentHeightAnchor = NSLayoutConstraint(item: self.attachmentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        self.attachmentHeightAnchor?.isActive = true

        self.textView.leadingAnchor.constraint(equalTo: self.inputContainerView.leadingAnchor).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: self.inputContainerView.trailingAnchor).isActive = true
        self.textView.topAnchor.constraint(equalTo: self.attachmentView.bottomAnchor).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: self.inputContainerView.bottomAnchor).isActive = true
        self.textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    private func setupGestures() {
        let panRecognizer = UIPanGestureRecognizer { [unowned self] (recognizer) in
            self.handle(pan: recognizer)
        }
        panRecognizer.delegate = self
        self.overlayButton.addGestureRecognizer(panRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer { [unowned self] (recognizer) in
            self.handle(longPress: recognizer)
        }
        longPressRecognizer.delegate = self
        self.overlayButton.addGestureRecognizer(longPressRecognizer)
    }

    private func setupHandlers() {

        KeyboardManger.shared.$currentEvent.mainSink { event in
            switch event {
            case .willHide(_):
                self.textView.updateInputView(type: .keyboard, becomeFirstResponder: false)
                self.plusAnimationView.play(toProgress: 0.0)
            case .didShow(_):
                break
            default:
                break
            }
        }.store(in: &self.cancellables)

        self.textView.textDidUpdate = { [unowned self] text in
            self.handleTextChange(text)
        }

        self.overlayButton.didSelect { [unowned self] in
            if !self.textView.isFirstResponder {
                self.textView.becomeFirstResponder()
            }
        }

        self.plusAnimationView.didSelect { [unowned self] in
            self.updateInputType()
        }

        self.textView.confirmationView.button.didSelect { [unowned self] in
            self.resetAlertProgress()
        }

        self.attachmentView.$messageKind.mainSink { (kind) in
            self.currentMessageKind = kind ?? .text(String())
            self.textView.setPlaceholder(for: self.currentMessageKind)
            self.attachmentHeightAnchor?.constant = self.attachmentView.messageKind.isNil ? 0 : 100
            self.layoutNow()
        }.store(in: &self.cancellables)
    }

    // MARK: HANDLERS

    private func handleTextChange(_ text: String) {
        self.animateInputViews(with: text)

        switch self.currentMessageKind {
        case .text(_):
            self.currentMessageKind = .text(text)
        case .photo(photo: let photo, _):
            self.currentMessageKind = .photo(photo: photo, body: text)
        case .video(video: let video, _):
            self.currentMessageKind = .video(video: video, body: text)
        default:
            break
        }

        guard let channelDisplayable = self.activeChannel,
            text.count > 0,
            case ChannelType.channel(let channel) = channelDisplayable.channelType else { return }
        // Twilio throttles this call to every 5 seconds
        channel.typing()
    }

    private func updateInputType() {
        // If keyboard, then show attachments
        // If attachments & currentKind != .text, Then still show x
        // If progess is greater than 0 and pressed, reset attachment view.

        let currentType = self.textView.currentInputView
        let currentProgress = self.plusAnimationView.currentProgress

        if currentType == .keyboard {
            if self.attachmentView.attachment.isNil {
                let newType: InputViewType = .attachments
                self.textView.updateInputView(type: newType)
            } else {
                self.attachmentView.configure(with: nil)
            }

            let toProgress: CGFloat = currentProgress == 0 ? 1.0 : 0.0
            self.plusAnimationView.play(fromProgress: currentProgress, toProgress: toProgress, loopMode: .playOnce, completion: nil)

        } else if currentProgress > 0 {

            let newType: InputViewType = .keyboard

            if self.attachmentView.attachment.isNil {
                let toProgress: CGFloat = currentProgress == 0 ? 1.0 : 0.0
                self.plusAnimationView.play(fromProgress: currentProgress, toProgress: toProgress, loopMode: .playOnce, completion: nil)
            }
            self.textView.updateInputView(type: newType)

        } else {
            // progress is greater that 0 and input type is attachments
            self.attachmentView.messageKind = nil
        }
    }

    private func animateInputViews(with text: String) {

        let inputOffset: CGFloat
        if text.count > 0 {
            inputOffset = 0
        } else {
            inputOffset = 53
        }

        guard let constraint = self.inputLeadingContstaint, inputOffset != constraint.constant else { return }

        UIView.animate(withDuration: Theme.animationDuration) {
            self.plusAnimationView.transform = inputOffset == 0 ? CGAffineTransform(scaleX: 0.5, y: 0.5) : .identity
            self.plusAnimationView.alpha = inputOffset == 0 ? 0.0 : 1.0
            self.inputLeadingContstaint?.constant = inputOffset
            self.layoutNow()
        }
    }

    // MARK: PUBLIC

    func edit(message: Messageable) {

        switch message.kind {
        case .text(let body):
            self.textView.text = body
        case .attributedText(let body):
            self.textView.text = body.string
        case .photo(photo: _, body: let body):
            self.textView.text = body
        case .video(video: _, body: let body):
            self.textView.text = body
        default:
            return
        }

        self.currentContext = message.context
        self.currentMessageKind = message.kind
        self.editableMessage = message

        self.textView.becomeFirstResponder()
    }

    func reset() {
        self.textView.reset()
        self.textView.alpha = 1
        self.attachmentView.alpha = 1
        self.attachmentView.configure(with: nil)
        self.attachmentView.messageKind = nil
        self.resetAlertProgress()
        self.textView.countView.isHidden = true
    }

    func resetAlertProgress() {
        self.currentContext = .casual
        self.alertProgressView.width = 0
        self.alertProgressView.set(backgroundColor: .red)
        self.alertProgressView.alpha = 1
        self.alertProgressView.layer.removeAllAnimations()
        self.textView.updateInputView(type: .keyboard)
    }
}

extension InputAccessoryView: AttachmentViewControllerDelegate {
    func attachementView(_ controller: AttachmentViewController, didSelect attachment: Attachment) {
        self.attachmentView.configure(with: attachment)
        self.updateInputType() // Needs to be called after configure
    }
}

class AlertProgressView: View {}
