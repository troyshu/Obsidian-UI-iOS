//
//  NumberExtensions.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension Double {

    /**
    Discounts by a percentage between 0 and 1

    - parameter percent: The amount to discount. A value between 0 and 1.
    - returns: The remaining value.
    */
    public func discountedBy(_ percent: Double) -> Double {
        return self * (1 - percent)
    }
}
