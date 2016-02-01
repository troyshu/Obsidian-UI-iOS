//
//  Types.swift
//  Alfredo
//
//  Created by Nick Lee on 9/24/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public struct Pair<T, U> {

    /// :nodoc:
    public var first: T

    /// :nodoc:
    public var second: U

    /**
    Initializes a new Pair

    - parameter first: The first item in the pair
    - parameter second: The second item in the pair

    - returns: An initialized Pair

    */
    public init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }

}


/// :nodoc:
public typealias VoidFunction = () -> ()
