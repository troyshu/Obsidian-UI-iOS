//
//  UIControlExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

private class ControlHandler {

    fileprivate let handler: (_ sender: UIControl) -> ()

    fileprivate init(handler: @escaping (_ sender: UIControl) -> ()) {
        self.handler = handler
    }

    fileprivate dynamic func call(_ sender: UIControl) {
        handler(sender)
    }

}


/**
Binds a closure to a UIControl's events

- parameter control: The control to bind to
- parameter events: A bitmask specifying the control events for which closure will be executed
- parameter target: The target that should be passed to the handler.  The target will not be retained.
- parameter handler: A closure that will fire when the events are triggered

*/
public func addHandler<T: UIControl, U: AnyObject>(_ control: T, events: UIControlEvents, target: U, handler: @escaping (_ target: U) -> ((_ sender: T) -> ())) {

    let newClosure = { [weak target] (sender: UIControl) -> Void in
        if let t = target, let theSender = sender as? T {
            let h1 = handler(t)
            h1(theSender)
        }
    }

    let controlHandler = ControlHandler(handler: newClosure)

    let raw = events.rawValue
    let fakePointer = UnsafeRawPointer(bitPattern: raw)

    let object: UIControl = control

    objc_setAssociatedObject(object, fakePointer, controlHandler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    control.addTarget(controlHandler, action: #selector(ControlHandler.call(_:)), for: events)

}
