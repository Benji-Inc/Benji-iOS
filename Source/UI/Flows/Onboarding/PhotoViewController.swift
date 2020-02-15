//
//  LoginProfilePhotoViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/12/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures
import TMROLocalization
import Lottie
import ReactiveSwift

enum PhotoState {
    case initial
    case scan
    case confirm
    case error
    case finish
}

class PhotoViewController: ViewController, Sizeable, Completable {
    typealias ResultType = Void

    var onDidComplete: ((Result<Void, Error>) -> Void)?

    private lazy var cameraVC: FaceDetectionViewController = {
        let vc: FaceDetectionViewController = UIStoryboard(name: "FaceDetection", bundle: nil).instantiateViewController(withIdentifier: "FaceDetection") as! FaceDetectionViewController

        return vc
    }()

    private let animationView = AnimationView(name: "face_scan")
    private let avatarView = AvatarView()

    private let beginButton = Button()
    private let confirmButton = LoadingButton()
    private let retakeButton = Button()

    private let buttonContainer = View()
    private var buttonContainerRect: CGRect?

    private var currentState = MutableProperty<PhotoState>(.initial)

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .background1)

        self.view.addSubview(self.animationView)
        self.view.addSubview(self.avatarView)
        self.addChild(viewController: self.cameraVC)

        self.avatarView.layer.borderColor = Color.purple.color.cgColor
        self.avatarView.layer.borderWidth = 4
        self.avatarView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self.avatarView.alpha = 0
        self.view.addSubview(self.buttonContainer)

        self.cameraVC.view.alpha = 1
        self.cameraVC.didCapturePhoto = { [unowned self] image in
             self.update(image: image)
        }

        self.currentState.producer
            .skipRepeats()
            .on { [unowned self] (state) in
                self.handle(state: state)
        }.start()

        self.beginButton.set(style: .normal(color: .blue, text: "Begin"))
        self.beginButton.didSelect = { [unowned self] in
            self.currentState.value = .scan
        }

        self.retakeButton.set(style: .normal(color: .red, text: "Retake"))
        self.retakeButton.didSelect = { [unowned self] in
            self.currentState.value = .scan
        }

        self.confirmButton.set(style: .normal(color: .blue, text: "Continue"))
        self.confirmButton.didSelect = { [unowned self] in
            self.currentState.value = .finish
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.animationView.size = CGSize(width: 140, height: 140)
        self.animationView.centerOnXAndY()

        self.cameraVC.view.expandToSuperviewSize()

        let height = self.view.height * 0.6
        let width = height * 0.7
        self.avatarView.size = CGSize(width: width, height: height)
        self.avatarView.top = 30
        self.avatarView.centerOnX()
        self.avatarView.roundCorners()

        let rect = self.buttonContainerRect ?? CGRect(x: Theme.contentOffset,
                                                      y: self.view.bottom,
                                                      width: self.view.width - (Theme.contentOffset * 2),
                                                      height: Theme.buttonHeight)

        self.buttonContainer.frame = rect
    }

    private func handle(state: PhotoState) {
        switch state {
        case .initial:
            self.handleInitialState()
        case .scan:
            self.handleScanState()
        case .confirm:
            self.handleConfirmState()
        case .error:
            self.handleErrorState()
        case .finish:
            self.handleFinishState()
        }
    }

    private func handleInitialState() {

        //show begin
        //show animation
    }

    private func handleScanState() {
        //show scan
        //show capture
        self.cameraVC.begin()
    }

    private func handleConfirmState() {
        //Capture photo
        self.cameraVC.capturePhoto()
        // show Result
        //Show continue
        //Show retake
    }

    private func handleErrorState() {
        self.complete(with: .failure(ClientError.generic))
    }

    private func handleFinishState() {
        self.complete(with: .success(()))

        //Show loading on button
        self.confirmButton.isLoading = true
        //Upload and dismiss
    }

    private func update(image: UIImage) {
        guard let fixed = image.fixedOrientation() else { return }

        self.avatarView.set(avatar: fixed)
        self.saveProfilePicture(image: fixed)

        UIView.animate(withDuration: Theme.animationDuration) {
            self.avatarView.transform = .identity
            self.avatarView.alpha = 1
            self.cameraVC.view.alpha = 0
            self.view.setNeedsLayout()
        }
    }

    func saveProfilePicture(image: UIImage) {
        guard let imageData = image.pngData(), let current = User.current() else { return }

        // NOTE: Remember, we're in points not pixels. Max image size will
        // depend on image pixel density. It's okay for now.
        let maxAllowedDimension: CGFloat = 50.0
        let longSide = max(image.size.width, image.size.height)

        var scaledImage: UIImage
        if longSide > maxAllowedDimension {
            let scaleFactor: CGFloat = maxAllowedDimension / longSide
            scaledImage = image.scaled(by: scaleFactor)
        } else {
            scaledImage = image
        }

        if let scaledData = scaledImage.pngData() {
            let scaledImageFile = PFFileObject(name:"small_image.png", data: scaledData)
            current.smallImage = scaledImageFile
        }

        let largeImageFile = PFFileObject(name:"image.png", data: imageData)
        current.largeImage = largeImageFile

        current.saveLocalThenServer()
            .observe { (result) in
                switch result {
                case .success(_):
                    self.currentState.value = .confirm
                case .failure(_):
                    self.currentState.value = .error
                }
                self.confirmButton.isLoading = false
        }
    }
}