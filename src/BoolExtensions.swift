//
//  BoolExtensions.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/17/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

postfix operator ¡
prefix operator ¡

/**
 Prefix and postfix operator ¡ inverts Bool value before and after it has been evaluated.

 Use ⌥ + 1 keys for the character ¡.

 */
public protocol Invertable {
    postfix func ¡ (flag: inout Self) -> Self
    prefix func ¡ (flag: inout Self) -> Self
}

extension Bool : Invertable {
    /// :nodoc:
    public static prefix func ¡ (flag: inout Bool) -> Bool {
        flag = !flag
        return flag
    }
    
    /// :nodoc:
    public static postfix func ¡ (flag: inout Bool) -> Bool {
        flag = !flag
        return !flag
    }
}
