//
//  UIAlertControllerExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/22/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension UIAlertController {

    /**
    Creates and returns a view controller for displaying the passed error message to the user.

    - parameter errorString: Descriptive text that provides additional details about the error.

    - returns: An initialized alert controller object.

    */
    public convenience init(errorString: String) {
        self.init(title: L("Error"), message: errorString, preferredStyle: .Alert)
        let action = UIAlertAction(title: L("OK"), style: .Cancel, handler: nil)
        addAction(action)
    }

}
