//
//  ColorButton.swift
//  Alfredo
//
//  Created by Nick Lee on 9/22/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable open class ColorButton: UIButton {

    fileprivate static let ButtonDimmingColor = UIColor.white.withAlphaComponent(0.1)

    /// The button's color.  Setting this will adjust the background images for the various control states.
    @IBInspectable open var color: UIColor? {
        didSet {
            if let c = color {
                setBackgroundColor(c, forState: UIControlState())
            }
        }
    }

    /**
    Sets the background color for the passed control state

    - parameter color: The color to set
    - parameter state: The state for which the color should be set

    */
    open func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {

        setBackgroundImage(color.image, for: state)

        if state == UIControlState() && backgroundImage(for: .highlighted) == nil {
            let highlightedColor = blendColor(color, ColorButton.ButtonDimmingColor, -, true).image
            setBackgroundImage(highlightedColor, for: .highlighted)
        }

    }

}
