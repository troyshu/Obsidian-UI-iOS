//
//  FloatingView.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/2/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
A view that positions itself based on the scrolling of its superview.
Recommended use is as a header or footer view for a UITableView.

This view can float in place (FloatAtTop, FloatAtBottom, or FloatInPlace)
regardless of its superview's scrolling or it can stick to the top (FloatAboveContent) or
bottom (FloatBelowContent) of the superview until the content is scrolled and pushes it out of view.

*/
open class FloatingView: UIView {

    /// How the view behaves when its superview is scrolled
    public enum FloatBehavior {
        /// View will stay above content and move out of view when scrolled.
        case floatAboveContent
        /// View will stay below content and move out of view when scrolled.
        case floatBelowContent
        /// View will always be visible at top of view and not effected by scrolling.
        case floatAtTop
        /// View will always be visible at bottom of view and not effected by scrolling.
        case floatAtBottom
        /// View will stay in its visible position.
        case floatInPlace
    }

    /// How the view behaves when its superview is scrolled
    open var floatBehavior = FloatBehavior.floatAtTop

    /// Call this inside the scrollViewDidScroll of your UIScrollViewDelegate or UITableViewDelegate.
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let verticalScrollDistance = scrollView.contentOffset.y
        let topContentInset = scrollView.contentInset.top
        let restingScrollPosition = scrollView.contentInset.top + self.frame.size.height
        var newFrame = self.frame
        var newFrameOriginY = newFrame.origin.y
        let contentHeight = scrollView.contentSize.height

        switch floatBehavior {
        case .floatAboveContent:
            if verticalScrollDistance <= -topContentInset {
                newFrameOriginY = verticalScrollDistance + restingScrollPosition
            }
            break
        case .floatBelowContent:
            if verticalScrollDistance > (contentHeight + newFrame.height - scrollView.height) {
                newFrameOriginY = scrollView.height - newFrame.height + verticalScrollDistance
            }
            break
        case .floatAtTop:
            newFrameOriginY = verticalScrollDistance
            break
        case .floatAtBottom:
            newFrameOriginY = verticalScrollDistance + scrollView.height - newFrame.height
            break
        case .floatInPlace:
            newFrameOriginY += verticalScrollDistance
            break
        }

        newFrame.origin.y = newFrameOriginY
        frame = newFrame
    }

}
