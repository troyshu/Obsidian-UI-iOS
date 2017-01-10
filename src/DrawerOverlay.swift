//
//  DrawerOverlayViewController.swift
//  Alfredo
//
//  Created by Nick Lee on 8/26/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit


private struct DrawerPresentationControllerConstants {
    static let AnimationDuration: TimeInterval = 0.25
    static let DefaultDrawerWidth: CGFloat = 320.0
    static let DefaultBackgroundColor = UIColor.black.withAlphaComponent(0.75)
}

/// The side on which the drawer should be presented
public enum DrawerSide: Int {
    case left
    case right
}

private final class DrawerPresentationController: UIPresentationController {

    // MARK: Public Properties

    fileprivate var dimmingColor: UIColor = DrawerPresentationControllerConstants.DefaultBackgroundColor

    // MARK: Private Properties

    fileprivate let side: DrawerSide
    fileprivate let dimmingView = UIView()

    // MARK: Initialization

    fileprivate init(presentedViewController: UIViewController!, presentingViewController: UIViewController!, side: DrawerSide) {
        self.side = side
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    // MARK: Presentation

    fileprivate override func presentationTransitionWillBegin() {

        super.presentationTransitionWillBegin()

        dimmingView.backgroundColor = dimmingColor
        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0

        let tap = UITapGestureRecognizer(target: self, action: #selector(DrawerPresentationController.dismissController(_:)))
        dimmingView.addGestureRecognizer(tap)

        containerView!.addSubview(dimmingView)
        containerView!.addSubview(presentedView!)

        let coordinator = presentingViewController.transitionCoordinator

        coordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 1.0
            }, completion: nil)

    }

    fileprivate override func dismissalTransitionWillBegin() {

        let coordinator = presentingViewController.transitionCoordinator

        coordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.0
            }, completion: nil)

    }

    fileprivate override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        dimmingView.removeFromSuperview()
    }

    fileprivate override var frameOfPresentedViewInContainerView : CGRect {

        let drawerWidth = DrawerPresentationControllerConstants.DefaultDrawerWidth

        switch side {
        case .left:
            return CGRect(origin: CGPoint.zero, size: CGSize(width: drawerWidth, height: containerView!.height))
        case .right:
            return CGRect(origin: CGPoint(x: containerView!.width - drawerWidth, y: 0.0), size: CGSize(width: drawerWidth, height: containerView!.height))
        }

    }

    // MARK: Actions

    fileprivate dynamic func dismissController(_ sender: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

}

private final class DrawerAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    fileprivate let presenting: Bool
    fileprivate let side: DrawerSide

    fileprivate init(side: DrawerSide, presenting: Bool) {
        self.side = side
        self.presenting = presenting
        super.init()
    }

    @objc fileprivate func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DrawerPresentationControllerConstants.AnimationDuration
    }

    @objc fileprivate func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)

        if let targetController = (presenting ? toController : fromController) {

            let destinationFrame = transitionContext.finalFrame(for: targetController)
            var originFrame = destinationFrame

            var offset: CGFloat!

            switch side {
            case .left:
                offset = -destinationFrame.width
            case .right:
                offset = destinationFrame.width
            }

            originFrame.offset(offset, 0)

            targetController.view.frame = presenting ? originFrame : destinationFrame
            transitionContext.containerView.addSubview(targetController.view)

            let duration = transitionDuration(using: transitionContext)

            UIView.animate(withDuration: duration, animations: { () -> Void in
                targetController.view.frame = self.presenting ? destinationFrame : originFrame
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })

        }

    }

}

private final class _DrawerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    fileprivate let side: DrawerSide

    fileprivate init(side: DrawerSide) {
        self.side = side
        super.init()
    }

    @objc func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DrawerPresentationController(presentedViewController: presented, presentingViewController: presenting, side: side)
    }

    @objc func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimationController(side: side, presenting: true)
    }

    @objc func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimationController(side: side, presenting: false)
    }

}

private var delegates: [DrawerSide : UIViewControllerTransitioningDelegate] = [:]

func DrawerTransitioningDelegate(_ side: DrawerSide) -> UIViewControllerTransitioningDelegate {
    let delegate = delegates[side] ?? _DrawerTransitioningDelegate(side: side)
    delegates[side] = delegate
    return delegate
}
