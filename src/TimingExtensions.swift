//
//  TimingExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension NSTimeInterval {

    // MARK: Timing

    /**
    Runs the passed closure after the duration of the receiver (in seconds) has elapsed.

    - parameter closure: The closure to execute after the delay

    */
    public func delay(closure: () -> ()) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), closure)
    }

}

public extension NSNumber {

    // MARK: Timing

    /// Returns the receiver represented as an NSTimeInterval
    public var seconds: NSTimeInterval {
        return NSTimeInterval(self)
    }

    /// Returns the receiver (in minutes) represented as an NSTimeInterval
    public var minutes: NSTimeInterval {
        return seconds * 60.0
    }

    /// Returns the receiver (in hours) represented as an NSTimeInterval
    public var hours: NSTimeInterval {
        return minutes * 60.0
    }

    /// Returns the receiver (in days) represented as an NSTimeInterval
    public var days: NSTimeInterval {
        return hours * 24.0
    }

}
