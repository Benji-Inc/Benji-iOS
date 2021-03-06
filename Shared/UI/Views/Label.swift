//
//  Label.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import UIKit
import TMROLocalization

/// A custom label that automatically applies font, color and kerning attributes to text set through the standard text member variable.
class Label: UILabel {

    override var text: String? {
        get { return super.text }
        set {
            guard let string = newValue else {
                // No need to apply attributes to a nil string.
                super.text = nil
                return
            }
            self.setTextWithAttributes(string)
        }
    }

    override var attributedText: NSAttributedString? {
        get { return super.attributedText }
        set {
            guard let attributedString = newValue else {
                super.attributedText = nil
                return
            }
            self.setAttributedTextWithAttributes(attributedString)
        }
    }

    /// Kerning to be applied to all text in this label. If an attributed string is set manually, there is no guarantee that this variable
    /// will be accurate, but setting it will update kerning on all text in the label.
    var kerning: CGFloat {
        didSet {
            // Reload the current text with the new kerning value
            guard let text = self.text else { return }
            self.setTextWithAttributes(text)
        }
    }

    var stringCasing: StringCasing {
        didSet {
            guard let text = self.text else { return }
            self.setTextWithAttributes(text)
        }
    }

    /// The string attributes to apply to any text given this label's assigned font and font color.
    private var attributes: [NSAttributedString.Key : Any] {
        let font = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let textColor = self.textColor ?? UIColor.black
        return [NSAttributedString.Key.font: font,
                NSAttributedString.Key.kern: self.kerning,
                NSAttributedString.Key.foregroundColor: textColor]
    }

    // MARK: Lifecycle

    init(frame: CGRect = .zero,
         font: FontType,
         textColor: Color = .white) {
        
        self.kerning = font.kern
        self.stringCasing = .unchanged
        super.init(frame: frame)
        self.font = font.font
        self.textColor = textColor.color
        self.initializeLabel()
    }

    required init?(coder: NSCoder) {
        self.kerning = 0
        self.stringCasing = .unchanged
        super.init(coder: coder)
        self.initializeLabel()
    }

    func initializeLabel() {
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
    }

    // MARK: Setters

    func setText(_ localizedText: Localized?) {
        guard let localizedText = localizedText else {
            self.text = nil
            return
        }
        self.text = localized(localizedText)
    }

    func setFont(_ fontType: FontType) {
        self.font = fontType.font
        self.kerning = fontType.kern
    }

    func setTextColor(_ textColor: Color) {
        self.textColor = textColor.color
    }

    private func setTextWithAttributes(_ newText: String) {

        let string = self.stringCasing.format(string: newText)

        // Create an attributed string and add attributes to the entire range.
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes(self.attributes, range: NSRange(location: 0,
                                                                       length: attributedString.length))

        let fontSize: CGFloat = self.font?.pointSize ?? UIFont.systemFontSize
        // NOTE: Some emojis don't display properly with certain attributes applied to them
        // So remove attributes from emoji characters.
        for emojiRange in newText.getEmojiRanges() {
            attributedString.removeAttributes(atRange: emojiRange)
            if let emojiFont = UIFont(name: "AppleColorEmoji", size: fontSize) {
                attributedString.addAttributes([NSAttributedString.Key.font: emojiFont], range: emojiRange)
            }
        }

        super.attributedText = attributedString
    }

    /// Applies the font, color and kerning to the provided string while preserving any other attributes, then sets it as the attributed text.
    private func setAttributedTextWithAttributes(_ newText: NSAttributedString) {
        let attributedString = NSMutableAttributedString(string: newText.string)
        attributedString.addAttributes(newText.existingAttributes ?? [:])
        attributedString.addAttributes(self.attributes, range: NSRange(location: 0,
                                                                       length: attributedString.length))
        super.attributedText = attributedString
    }

    func set(attributed: AttributedString,
             alignment: NSTextAlignment = .left,
             lineCount: Int = 0,
             lineBreakMode: NSLineBreakMode = .byWordWrapping,
             stringCasing: StringCasing = .unchanged) {

        let string = stringCasing.format(string: attributed.string.string)
        let newString = NSMutableAttributedString(string: string)
        newString.addAttributes(attributed.attributes,
                                range: NSRange(location: 0, length: newString.length))
        // NOTE: Some emojis don't display properly with certain attributes applied to them
        for emojiRange in string.getEmojiRanges() {
            newString.removeAttributes(atRange: emojiRange)
        }

        self.attributedText = newString
        self.numberOfLines = lineCount
        self.lineBreakMode = lineBreakMode
        self.textAlignment = alignment
    }
}

extension Label {

    func setSize(withWidth width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) {
        self.size = self.getSize(withWidth: width, height: height)
    }

    func getSize(withWidth width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        guard let text = self.text,
              !text.isEmpty,
              let attText = self.attributedText else { return .zero }

        var attributes = attText.attributes(at: 0,
                                            longestEffectiveRange: nil,
                                            in: NSRange(location: 0, length: attText.length))
        if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
            let mutableStyle = NSMutableParagraphStyle()
            mutableStyle.setParagraphStyle(paragraphStyle)
            mutableStyle.lineBreakMode = .byWordWrapping
            attributes[.paragraphStyle] = mutableStyle
        }

        let maxSize = CGSize(width: width, height: height)

        let labelSize: CGSize = text.boundingRect(with: maxSize,
                                                  options: .usesLineFragmentOrigin,
                                                  attributes: attributes,
                                                  context: nil).size

        return labelSize
    }
}
