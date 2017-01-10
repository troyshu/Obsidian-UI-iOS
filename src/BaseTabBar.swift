//
//  BaseTabBar.swift
//  Alfredo
//
//  Created by Nick Lee on 8/21/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

open class BaseTabBar: UIView {

    /// A weak reference to the parent tab bar controller
    open weak var delegate: TabBarDelegate!

    /// A method called by the parent tab bar controller when the layout should change
    open func layout() {}

    /// A method called by the parent tab bar controller when the receiver should update its UI for a selected tab
    open func selectTab(_ index: Int) {}

    /// This method must be overridden to return the frame for the tab at the passed index
    open func frameForTab(_ index: Int) -> CGRect {
        return CGRect.zero
    }

}
