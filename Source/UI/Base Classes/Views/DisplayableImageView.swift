//
//  DisplayableImageView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/4/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

protocol DisplayableDelegate {
    func didSet(displayable: ImageDisplayable)
}

class DisplayableImageView: View {

    var delegate: DisplayableDelegate?

    private(set) var imageView = UIImageView()

    var displayable: ImageDisplayable {
        didSet {
            self.updateImageView()
            self.setNeedsLayout()
            self.delegate?.didSet(displayable: self.displayable)
        }
    }

    init(displayable: ImageDisplayable = UIImage()) {
        self.displayable = displayable
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.displayable = UIImage()
        super.init(coder: aDecoder)
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .clear)
        self.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFill
        self.updateImageView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.frame = self.bounds
    }

    private func updateImageView() {
        if let photo = self.displayable.photo {
            self.imageView.image = photo
        } else if let user = self.displayable.user {
            self.downloadAndSetImage(for: user)
        } else if let objectID = self.displayable.userObjectID {
            self.findUser(with: objectID)
        }
    }

    private func downloadAndSetImage(for user: PFUser) {
        guard let imageFile = user["profilePicture"] as? PFFileObject else { return }
        
        imageFile.getDataInBackground { (imageData: Data?, error: Error?) in
            guard let data = imageData else { return }
            let image = UIImage(data: data)
            self.imageView.image = image
        }
    }

    private func findUser(with objectID: String) {
        PFUser.cachedQuery(for: objectID, completion: { (object, error) in
            if let user = object as? PFUser {
                self.downloadAndSetImage(for: user)
            } else {
                print(ClientError.message(detail: "FAILED TO FIND USER"))
            }
        })
    }
}
