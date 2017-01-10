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
open class VerticallyAlignedLabel: UILabel {

    /// Where the text posisitions itself vertically in the view.
    public enum VerticalAlignment {
        case top, middle, bottom
    }

    /// Where the text positions itself.
    open var verticalAlignment = VerticalAlignment.middle {
        didSet {
            setNeedsDisplay()
        }
    }

    override open func drawText(in rect: CGRect) {
        if let stringText = text {
            
            let stringTextAsNSString = stringText as NSString
            
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(frame.width, CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil).size

            switch verticalAlignment {
            case .top:
                super.drawText(in: CGRect(0, 0, frame.width, ceil(labelStringSize.height)))
                break
            case .middle:
                let textHeight = ceil(labelStringSize.height)
                super.drawText(in: CGRect(0, (frame.height - textHeight) / 2, frame.width, textHeight))
                break
            case .bottom:
                let textHeight = ceil(labelStringSize.height)
                super.drawText(in: CGRect(0, frame.height - textHeight, frame.width, textHeight))
                break
            }

        } else {
            super.drawText(in: rect)
        }
    }
}
