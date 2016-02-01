//
//  VerticallyAlignedLabel.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/1/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
A text label that can be set to Top, Middle, or Bottom alignment.
This class will not truncate text.

*/
public class VerticallyAlignedLabel: UILabel {

    /// Where the text posisitions itself vertically in the view.
    public enum VerticalAlignment {
        case Top, Middle, Bottom
    }

    /// Where the text positions itself.
    public var verticalAlignment = VerticalAlignment.Middle {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func drawTextInRect(rect: CGRect) {
        if let stringText = text {
            
            let stringTextAsNSString = stringText as NSString
            
            let labelStringSize = stringTextAsNSString.boundingRectWithSize(CGSize(frame.width, CGFloat.max),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil).size

            switch verticalAlignment {
            case .Top:
                super.drawTextInRect(CGRect(0, 0, frame.width, ceil(labelStringSize.height)))
                break
            case .Middle:
                let textHeight = ceil(labelStringSize.height)
                super.drawTextInRect(CGRect(0, (frame.height - textHeight) / 2, frame.width, textHeight))
                break
            case .Bottom:
                let textHeight = ceil(labelStringSize.height)
                super.drawTextInRect(CGRect(0, frame.height - textHeight, frame.width, textHeight))
                break
            }

        } else {
            super.drawTextInRect(rect)
        }
    }
}
