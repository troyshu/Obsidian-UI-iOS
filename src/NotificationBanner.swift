//
//  NotificationBanner.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/2/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

///This delegate responds to taps on the banner view.
public protocol NotificationBannerDelegate {

    /// Called when the banner is tapped
    func bannerTapped(_ banner: NotificationBanner)

    /// Called when the banner begins to animage-in
    func willBeginDisplayingBanner(_ banner: NotificationBanner)

    /// Called when the banner is done animating-in
    func didDisplayBanner(_ banner: NotificationBanner)

    /// Called when the banner begins to animate-out
    func willEndDisplayingBanner(_ banner: NotificationBanner)

    /// Called when the banner has fully animated-out
    func didEndDisplayingBanner(_ banner: NotificationBanner)
}

/**
A view that drops-down from the top of a view controller.
Can be shown in any UIView or UINavigationController by calling
presentInView or presentInViewController.

If you would like to present this view over a UITableview it is recommened
that you present this in a UINavigationController that contains the table view.
Then set the top contentInset of the table to fit the height of the banner.

*/
open class NotificationBanner: FloatingView {

    // MARK: Public Properties

    /// The text of the banner.
    open var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    /// The font of the text.
    open var font: UIFont {
        get {
            return label.font
        }
        set {
            label.font = newValue
        }
    }

    /// The color of the text.
    open var textColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }

    /// The duration of the move in and out animation
    open var animationDuration = 0.4

    /// The delegate responds to taps on the banner.
    open var delegate: NotificationBannerDelegate?

    /// The time that the banner is fully in view. Default is 3 seconds.
    open var displayTime = 3.0

    // MARK: Private Properties
    fileprivate var label = UILabel()

    // MARK: Initialization

    /// :nodoc:
    public init(message: String, color: UIColor = UIColor.darkGray, textColor: UIColor = UIColor.white, height: CGFloat = 35, duration: Double = 3.0) {
        super.init(frame: CGRect.zero)
        commonInit()
        configureBanner(color: color, textColor: textColor, message: message, duration: duration, height: height)
    }

    /// :nodoc:
    convenience public init() {
        self.init(frame: CGRect.zero)
        commonInit()
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// :nodoc:
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    fileprivate func commonInit() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationBanner.handleTap))
        addGestureRecognizer(tapRecognizer)

        addSubview(label)
        label.textAlignment = NSTextAlignment.center
    }

    // MARK: Presentation

    /**
    Presents the view ito a UINavigationController.

    - parameter navigationController: The navigationController to present into.

    */
    open func presentInNavigationController(_ navigationController: UINavigationController) {
        let view = navigationController.view
        let topBarHeight = navigationController.navigationBar.frame.height
        frame = CGRect(0, -topBarHeight, (view?.width)!, height)
        view?.insertSubview(self, belowSubview: navigationController.navigationBar)

        show(topOfView: UIApplication.shared.statusBarFrame.height + navigationController.navigationBar.frame.height, width: (view?.width)!, height: height + topBarHeight)
    }

    /**
    Presents the view ito a UINavigationController.

    - parameter navigationController: The navigationController to present into.
    - parameter originY: The Y compontent of the origin of the presented banner.

    */
    open func presentInNavigationController(_ navigationController: UINavigationController, originY: CGFloat) {
        let view = navigationController.view
        frame = CGRect(0, -originY, (view?.width)!, height)
        view?.insertSubview(self, belowSubview: navigationController.navigationBar)

        show(topOfView: originY, width: (view?.width)!, height: height + originY)
    }

    /**
    Presents the view ito a UIView.

    - parameter view: The view to present into.

    */
    open func presentInView(_ view: UIView) {
        frame = CGRect(0, -height, view.width, height)
        view.addSubview(self)

        show(topOfView: 0, width: view.width, height: height)
    }

    fileprivate func configureBanner(color: UIColor = UIColor.darkGray, textColor: UIColor = UIColor.white, message: String, duration: Double = 3.0, height: CGFloat = 35) {
        text = message
        backgroundColor = color
        self.textColor = textColor
        displayTime = duration
        frame.size.height = height
    }

    fileprivate func show(topOfView originY: CGFloat, width: CGFloat, height: CGFloat) {
        label.frame = bounds

        var visibleFrame = frame
        visibleFrame.origin.y = 0 + originY

        delegate?.willBeginDisplayingBanner(self)
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.frame = visibleFrame
            }, completion: { (finished) -> Void in
                let _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(NotificationBanner.animateOutBanner), userInfo: nil, repeats: false)
        }) 
    }

    func animateOutBanner() {
        delegate?.willEndDisplayingBanner(self)

        var hiddenFrame = frame
        hiddenFrame.origin.y = -(frame.height + 100)

        UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.frame = hiddenFrame
            }, completion: { (finished) -> Void in
                self.delegate?.didEndDisplayingBanner(self)
                self.removeFromSuperview()
        })
    }

    // MARK: Action

    func handleTap() {
        delegate?.bannerTapped(self)
    }

}
