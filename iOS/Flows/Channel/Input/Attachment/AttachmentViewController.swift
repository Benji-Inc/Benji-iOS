//
//  AttachementInputView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/29/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Photos
import Combine

protocol AttachmentViewControllerDelegate: class {
    func attachmentView(_ controller: AttachmentViewController, didSelect attachment: Attachement)
}

class AttachmentViewController: CollectionViewController<AttachementCell, AttachmentCollectionViewManager>, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))

    unowned let delegate: AttachmentViewControllerDelegate

    private lazy var imagePickerVC = UIImagePickerController()

    init(with delegate: AttachmentViewControllerDelegate) {
        self.delegate = delegate
        super.init(with: AttachmentCollectionView())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        guard let window = UIWindow.topWindow() else { return }
        self.view.size = CGSize(width: window.width, height: window.height * 0.4)

        let color = Color.background1.color.withAlphaComponent(0.9)
        self.view.backgroundColor = color
        self.view.insertSubview(self.blurView, belowSubview: self.collectionView)

        self.collectionViewManager.didSelectPhotoOption = { [unowned self] in
            self.presentPicker(for: .camera)
        }

        self.collectionViewManager.didSelectLibraryOption = { [unowned self] in
            self.presentPicker(for: .photoLibrary)
        }

        if let attachmentCollectionView = self.collectionView as? AttachmentCollectionView {
            attachmentCollectionView.didTapAuthorize = { [unowned self] in
                self.requestAuthorization()
                    .mainSink(receivedResult: { (result) in
                        switch result {
                        case .success():
                            self.fetchAssets()
                        case .error(_):
                            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }).store(in: &self.cancellables)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.checkPhotoAuthorizationStatus()
    }

    private func checkPhotoAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case .authorized, .limited:
            self.fetchAssets()
        default:
            break
        }
    }

    private func requestAuthorization() -> Future<Void, Error> {
        return Future { promise in
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized, .limited:
                    promise(.success(()))
                default:
                    promise(.failure(ClientError.message(detail: "Failed to authorize")))
                }
            })
        }
    }

    private func fetchAssets() {
        let photosOptions = PHFetchOptions()
        photosOptions.fetchLimit = 20
        photosOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                              PHAssetMediaType.image.rawValue)
        photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: photosOptions)

        var attachments: [Attachement] = []

        for index in 0...result.count - 1 {
            let asset = result.object(at: index)
            let attachement = Attachement(with: asset)
            attachments.append(attachement)
        }

        self.collectionViewManager.set(newItems: attachments)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.blurView.expandToSuperviewSize()

        self.collectionView.expandToSuperviewWidth()
        self.collectionView.pin(.top)
        self.collectionView.height = self.view.height - self.view.safeAreaInsets.bottom
    }

    private func presentPicker(for type: UIImagePickerController.SourceType) {
        self.imagePickerVC.delegate = self
        self.imagePickerVC.sourceType = type
        self.present(self.imagePickerVC, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.imagePickerVC.dismiss(animated: true, completion: nil)
        guard let asset = info[.phAsset] as? PHAsset else {
            print("Image not found!")
            return
        }

        if let asst = info[.phAsset] as? PHAsset {
            self.delegate.attachmentView(self, didSelect: Attachement(with: asst))
        } else if let _ = info[.originalImage] {

        }

        self.delegate.attachmentView(self, didSelect: Attachement(with: asset))
    }
}
