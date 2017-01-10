//
//  CharacterLabel.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/26/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import QuartzCore

open class CharacterLabel: UILabel, NSLayoutManagerDelegate {

    var oldCharacterTextLayers = [CATextLayer]()
    var newCharacterTextLayers = [CATextLayer]()
    let textStorage = NSTextStorage(string: "")
    let textContainer = NSTextContainer()
    let layoutManager = NSLayoutManager()
    var characterTextLayers = [CATextLayer]()

    override open var lineBreakMode: NSLineBreakMode {
        get {
            return super.lineBreakMode
        }

        set {
            textContainer.lineBreakMode = newValue
            super.lineBreakMode = newValue
        }

    }

    override open var numberOfLines: Int {
        get {
            return super.numberOfLines
        }

        set {
            textContainer.maximumNumberOfLines = newValue
            super.numberOfLines = newValue
        }

    }

    override open var bounds: CGRect {
        get {
            return super.bounds
        }

        set {
            textContainer.size = newValue.size
            super.bounds = newValue
        }

    }

    override open var text: String! {
        get {
            return super.text
        }
        set {
            let wordRange = NSRange(location: 0, length: newValue.utf16.count)
            let attributedText = NSMutableAttributedString(string: newValue)
            attributedText.addAttribute(NSForegroundColorAttributeName, value: self.textColor, range: wordRange)
            attributedText.addAttribute(NSFontAttributeName, value: self.font, range: wordRange)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: wordRange)

            self.attributedText = attributedText
        }
    }

    override open var attributedText: NSAttributedString! {
        get {
            return super.attributedText
        }
        set {
            if textStorage.string == newValue.string {
                return
            }

            cleanOutOldCharacterTextLayers()
            oldCharacterTextLayers = characterTextLayers
            textStorage.setAttributedString(newValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutManager()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayoutManager()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        setupLayoutManager()
    }

    func setupLayoutManager() {
        if !textStorage.layoutManagers.isEmpty {
            textStorage.addLayoutManager(layoutManager)
            layoutManager.addTextContainer(textContainer)
            textContainer.size = bounds.size
            textContainer.maximumNumberOfLines = numberOfLines
            textContainer.lineBreakMode = lineBreakMode
            layoutManager.delegate = self
        }
    }

    open func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        calculateTextLayers()
    }

    func calculateTextLayers() {
        characterTextLayers.removeAll(keepingCapacity: false)
        let attributedText = textStorage.string

        let wordRange = NSRange(location: 0, length: attributedText.characters.count)
        let attributedString = self.internalAttributedText()
        let layoutRect = layoutManager.usedRect(for: textContainer)

//        for var index = wordRange.location; index < wordRange.length+wordRange.location; index += 0 {
//            let glyphRange = NSRange(location: index, length: 1)
//            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange:nil)
//            let textContainer = layoutManager.textContainer(forGlyphAt: index, effectiveRange: nil)
//            var glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer!)
//            let location = layoutManager.location(forGlyphAt: index)
//            let kerningRange = layoutManager.range(ofNominallySpacedGlyphsContaining: index)
//
//            if kerningRange.length > 1 && kerningRange.location == index {
//                if !characterTextLayers.isEmpty {
//                    let previousLayer = characterTextLayers[characterTextLayers.endIndex-1]
//                    var frame = previousLayer.frame
//                    frame.size.width += glyphRect.maxX-frame.maxX
//                    previousLayer.frame = frame
//                }
//            }
//
//
//            glyphRect.origin.y += location.y-(glyphRect.height/2)+(self.bounds.size.height/2)-(layoutRect.size.height/2)
//
//
//            let textLayer = CATextLayer(frame: glyphRect, string: (attributedString?.attributedSubstring(from: characterRange))!)
//            initialTextLayerAttributes(textLayer)
//
//            layer.addSublayer(textLayer)
//            characterTextLayers.append(textLayer)
//
//            index += characterRange.length
//        }
    }

    func initialTextLayerAttributes(_ textLayer: CATextLayer) {

    }

    func internalAttributedText() -> NSMutableAttributedString! {
        let wordRange = NSRange(location: 0, length: textStorage.string.characters.count)
        let attributedText = NSMutableAttributedString(string: textStorage.string)
        attributedText.addAttribute(NSForegroundColorAttributeName, value: self.textColor.cgColor, range:wordRange)
        attributedText.addAttribute(NSFontAttributeName, value: self.font, range:wordRange)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        attributedText.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: wordRange)

        return attributedText
    }

    func cleanOutOldCharacterTextLayers() {
        //Remove all text layers from the superview
        for textLayer in oldCharacterTextLayers {
            textLayer.removeFromSuperlayer()
        }
        //clean out the text layer
        oldCharacterTextLayers.removeAll(keepingCapacity: false)
    }

}
