//
//  ToastScheduler.swift
//  Benji
//
//  Created by Benji Dodgson on 7/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

enum ToastType {
    case systemMessage(SystemMessage)
    case message(TCHMessage, TCHChannel)
    case channel(TCHChannel)
    case error(ClientError)
}

protocol ToastSchedulerDelegate: class {
    func didInteractWith(type: ToastType)
}

class ToastScheduler {
    static let shared = ToastScheduler()

    weak var delegate: ToastSchedulerDelegate?

    func schedule(toastType: ToastType) {
        var toast: Toast?
        switch toastType {
        case .systemMessage(let message):
            toast = self.createSystemMessageToast(for: message)
        case .message(let message, let channel):
            toast = self.createMessageToast(for: message, channel: channel)
        case .channel(let channel):
            toast = self.createChannelToast(for: channel)
        case .error(let error):
            toast = self.createErrorToast(for: error)
        }

        if let toast = toast {
            ToastQueue.shared.add(toast: toast)
        }
    }

    private func createSystemMessageToast(for systemMessage: SystemMessage) -> Toast? {
        let button = LoadingButton()
        button.set(style: .rounded(color: .background3, text: "VIEW")) {

        }
        return Toast(id: systemMessage.id + "system_message",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: systemMessage.text,
                     displayable: UIImage(),
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .systemMessage(systemMessage))
        })
    }

    private func createMessageToast(for message: TCHMessage, channel: TCHChannel) -> Toast? {
        guard let sid = message.sid,
            let body = message.body,
            !body.isEmpty else { return nil }

        return Toast(id: sid + "message",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: body,
                     displayable: message,
                     didTap: { [unowned self] in
                        self.delegate?.didInteractWith(type: .message(message, channel))
        })
    }

    private func createChannelToast(for channel: TCHChannel) -> Toast? {
        guard let sid = channel.sid else { return nil }

        return Toast(id: sid + "channel",
                     analyticsID: "ToastMessage",
                     priority: 1,
                     title: "New conversation added.",
                     displayable: channel,
                     didTap: {
                        self.delegate?.didInteractWith(type: .channel(channel))
        })
    }

    private func createErrorToast(for error: ClientError) -> Toast? {
        guard let image = UIImage(named: "error") else { return nil }

        return Toast(id: error.localizedDescription + "error",
                     analyticsID: "ToastSystemMessage",
                     priority: 1,
                     title: error.localizedDescription,
                     displayable: image,
                     didTap: {
                        self.delegate?.didInteractWith(type: .error(error))
        })
    }
}
