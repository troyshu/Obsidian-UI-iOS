//
//  UIResponderExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/19/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension UIResponder {

    /// The responder's parent view controller.  This is found by recursively walking up the responder chain.
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}
