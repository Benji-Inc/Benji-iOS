//
//  MessageInputView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageInputView: View {

    var onPanned: ((UIPanGestureRecognizer) -> Void)?
    var onAlertMessageInitiated: (() -> Void)?

    private let minHeight: CGFloat = 38

    let textView = InputTextView()
    let overlayButton = UIButton()
    private let alertProgressView = UIView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))

    private var alertAnimator: UIViewPropertyAnimator?

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .backgroundWithAlpha)

        self.addSubview(self.blurView)
        self.addSubview(self.alertProgressView)
        self.alertProgressView.set(backgroundColor: .red)
        self.alertProgressView.size = .zero 
        self.addSubview(self.textView)
        self.textView.minHeight = self.minHeight
        self.addSubview(self.overlayButton)

        self.overlayButton.onTap { [unowned self] (tap) in
            if !self.textView.isFirstResponder {
                self.textView.becomeFirstResponder()
            }
        }

        let panRecognizer = UIPanGestureRecognizer { [unowned self] (recognizer) in
            self.onPanned?(recognizer)
        }
        panRecognizer.delegate = self
        self.overlayButton.addGestureRecognizer(panRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer { [unowned self] (recognizer) in
            self.handle(longPress: recognizer)
        }
        longPressRecognizer.delegate = self
        self.overlayButton.addGestureRecognizer(longPressRecognizer)

        self.layer.masksToBounds = true
        self.layer.borderColor = Color.lightPurple.color.cgColor
        self.layer.borderWidth = Theme.borderWidth
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.layer.cornerRadius = Theme.cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let textViewWidth = self.width
        self.textView.size = CGSize(width: textViewWidth, height: self.textView.currentHeight)
        self.textView.left = 0
        self.textView.top = 0

        self.alertProgressView.height = self.height

        self.overlayButton.frame = self.bounds
        self.blurView.frame = self.bounds
    }

    private func handle(longPress: UILongPressGestureRecognizer) {

        switch longPress.state {
        case .possible:
            break
        case .began:
            self.alertAnimator?.stopAnimation(true)

            self.alertAnimator = UIViewPropertyAnimator(duration: 1,
                                                        curve: .linear,
                                                        animations: { [unowned self] in
                self.alertProgressView.size = CGSize(width: self.width, height: self.height)
            })
            self.alertAnimator?.addCompletion({ [unowned self] (position) in
                self.onAlertMessageInitiated?()
            })
            self.alertAnimator?.startAnimation()
        case .changed:
            break
        case .ended, .cancelled, .failed:
            self.alertAnimator?.stopAnimation(true)

            self.alertAnimator = UIViewPropertyAnimator(duration: 1,
                                                        curve: .linear,
                                                        animations: { [unowned self] in
                self.alertProgressView.size = CGSize(width: 0, height: self.height)
            })
            self.alertAnimator?.startAnimation()
        @unknown default:
            break
        }
    }
}

extension MessageInputView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
