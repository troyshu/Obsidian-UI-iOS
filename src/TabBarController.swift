//
//  TabBarController.swift
//  Alfredo
//
//  Created by Nick Lee on 8/21/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public protocol TabBarDelegate: class {

    /// returns the currently selected tab index
    var selectedTabIndex: Int { get }

    /// Called when the user selects a tab
    func selectTab(_ index: Int)

    /// A computed array of the tab names
    var tabNames: [String] { get }

}

open class TabBarController: UIViewController, TabBarDelegate {

    // MARK: Public Properties

    /// The view controllers managed by the tab bar
    open var viewControllers: [UIViewController] = [] {
        didSet {
            updateTabs()
            selectTab(0)
        }
    }

    /// A computed array of the tab names
    open var tabNames: [String] {
        return viewControllers.map { $0.title ?? L("Untitled") } ?? []
    }

    /// The index of the currently selected tab
    open fileprivate(set) var selectedTabIndex = 0

    /// The tab bar's height
    open var tabBarHeight: CGFloat = 50 {
        didSet {
            layoutTabBar()
        }
    }

    // MARK: Private Properties

    /// The controller's tab bar.  Defaults to nil, but will result in a crash if not set.
    open var tabBar: BaseTabBar! {
        didSet {
            tabBar.delegate = self
            view.addSubview(tabBar)
            layoutTabBar()
            updateTabs()
        }
    }

    fileprivate var controllerContainer: UIView = UIView()
    fileprivate var contentViewController: UIViewController?

    // MARK: Initialization

    /// :nodoc:
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Tab Bar Management

    fileprivate func layoutTabBar() {

        tabBar.x = 0
        tabBar.y = view.height - tabBarHeight
        tabBar.width = view.width
        tabBar.height = tabBarHeight

        controllerContainer.x = 0
        controllerContainer.y = 0
        controllerContainer.width = view.width
        controllerContainer.height = view.height - tabBarHeight

    }

    fileprivate func updateTabs() {
        tabBar?.layout()
    }

    /**
    Selects a tab

    - parameter tab: The index of the tab to select.

    */
    open func selectTab(_ tab: Int) {

        selectedTabIndex = tab
        tabBar.selectTab(tab)

        if let c = contentViewController {
            c.willMove(toParentViewController: nil)
            c.view.removeFromSuperview()
            c.removeFromParentViewController()
        }

        let new = viewControllers[tab]
        self.addChildViewController(new)
        new.view.frame = controllerContainer.bounds
        controllerContainer.addSubview(new.view)
        new.didMove(toParentViewController: self)

        contentViewController = new

    }

    // MARK: Lifecycle

    /// :nodoc:
    open override func loadView() {
        super.loadView()
        view.addSubview(controllerContainer)
    }

    /// :nodoc:
    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    /// :nodoc:
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTabBar()
    }

}
