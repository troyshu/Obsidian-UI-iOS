//
//  DispatchQueueExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/25/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension dispatch_queue_t {

    /**
    Performs an operation asynchronously on the receiving queue

    - parameter closure: The closure to enqueue.

    */
    public func async(closure: () -> ()) {
        dispatch_async(self, closure)
    }


    /**
    Performs an operation synchronously on the receiving queue

    - parameter closure: The closure to enqueue.

    */
    public func sync(closure: () -> ()) {
        dispatch_sync(self, closure)
    }

}
