//
//  LoopExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 9/3/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/// Runs the passed closure i times, passing a 0-based auto-incremented index as an argument to the closure each time
public func times(_ i: Int, _ closure: (Int) -> ()) {
    for x in 0 ..< i {
        closure(x)
    }
}

/// Runs the passed closure i times
public func times(_ i: Int, closure: () -> ()) {
    times(i) { (_: Int) in
        closure()
    }
}
