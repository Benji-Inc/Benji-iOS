//
//  Attachment.swift
//  Ours
//
//  Created by Benji Dodgson on 1/19/21.
//  Copyright © 2021 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Photos

struct Attachement: ManageableCellItem, Hashable {

    var id: String {
        return self.asset.localIdentifier
    }

    let asset: PHAsset
    var mediaItem: MediaItem?
    var audioItem: AudioItem?

    var messageKind: MessageKind? {

        switch self.asset.mediaType {
        case .unknown:
            return nil
        case .image:
            if let item = self.mediaItem {
                return .photo(item)
            } else {
                return nil
            }
        case .video:
            if let item = self.mediaItem {
                return .video(item)
            } else {
                return nil
            }
        case .audio:
            if let item = self.audioItem {
                return .audio(item)
            } else {
                return nil
            }
        @unknown default:
            return nil
        }
    }

    var info: [UIImagePickerController.InfoKey : Any]? {
        didSet {
            if let info = self.info {
                switch self.asset.mediaType {
                case .image:
                    self.mediaItem = PhotoAttachment(with: info)
                case .video:
                    self.mediaItem = VideoAttachment(with: info)
                case .audio:
                    self.audioItem = AudioAttachment(with: info)
                default:
                    break
                }
            }
        }
    }

    init(with asset: PHAsset) {
        self.asset = asset
    }

    static func == (lhs: Attachement, rhs: Attachement) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class AttachmentItem {

    let info: [UIImagePickerController.InfoKey : Any]

    init(with info: [UIImagePickerController.InfoKey : Any]) {
        self.info = info
    }
}

class AudioAttachment: AttachmentItem, AudioItem {

    var url: URL {
        return URL(string: "")!
    }

    var duration: Float {
        return 0.0
    }

    var size: CGSize {
        return .zero
    }
}

class VideoAttachment: AttachmentItem, MediaItem {
    
    var url: URL? {
        return info[.mediaURL] as? URL
    }

    var image: UIImage? {
        return info[.originalImage] as? UIImage
    }

    var size: CGSize {
        guard let asset = info[.phAsset] as? PHAsset else { return .zero }
        return CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
    }

    var fileName: String {
        guard let asset = info[.phAsset] as? PHAsset else { return String() }
        return asset.localIdentifier
    }

    var type: MediaType {
        return .video
    }

    var data: Data? {
        return nil // Not sure how to extract this
    }
}

class PhotoAttachment: AttachmentItem, MediaItem {

    var url: URL?

    var image: UIImage? {
        return self.info[.originalImage] as? UIImage
    }

    var size: CGSize {
        guard let asset = info[.phAsset] as? PHAsset else { return .zero }
        return CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
    }

    var fileName: String {
        guard let asset = info[.phAsset] as? PHAsset else { return String() }
        return asset.localIdentifier
    }

    var type: MediaType {
        return .photo
    }

    var data: Data? {
        guard let img = self.image else { return nil }
        return img.data
    }
}
