//
//  PlaceholderImageView.swift
//  Alfredo
//
//  Created by Eric Kunz on 10/9/15.
//  Copyright © 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

/**
A placeholder image view object will attempt to load an image from
its imageURL. If this fails, its placeholderImage or placeholderView
will be displayed.

After setting the placeholderImage or the placeholderView, set the frame
of the placeholderView for either to be visible.

*/
open class PlaceholderImageView: UIView, URLImageViewDelegate {

    // MARK: Public Properties

    /**
    An image to be displayed if this view's image could not be loaded.
    Setting this will replace the placeholderView.

    */
    open var placeholderImage: UIImage? {
        get {
            if let placeholder = placeholderView as? UIImageView {
                return placeholder.image
            } else {
                return nil
            }
        }
        set {
            let placeholder = UIImageView(image: newValue)
            placeholderView = placeholder
        }
    }

    /**
    A view to be displayed if this view's image could not be loaded.
    Setting this will replace the placeholderImage.

    */
    open var placeholderView: UIView? {
        willSet {
            if newValue == nil {
                placeholderView?.removeFromSuperview()
            }
        }
        didSet {
            if let v = placeholderView {
                placeholderView?.isHidden = imageView.image != nil
                addSubview(v)
            }
        }
    }

    /// The image to be displayed
    open var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue

            if image != nil {
                placeholderView?.isHidden = true
            } else {
                placeholderView?.isHidden = false
            }
        }
    }

    /// The URL of the image displayed in the view
    open var imageURL: URL? {
        get {
            return imageView.imageURL as URL?
        }
        set {
            if newValue == nil {
                placeholderView?.isHidden = false
            }

            imageView.imageURL = newValue
        }
    }

    /// The layout behavior for the view's image
    open var placeholderContentMode: UIViewContentMode? {
        didSet {
            if let mode = placeholderContentMode {
                placeholderView?.contentMode = mode
            }
        }
    }

    open var imageContentMode: UIViewContentMode? {
        didSet {
            if let mode = imageContentMode {
                imageView.contentMode = mode
            }
        }
    }

    // MARK: Private Properties

    fileprivate var imageView = URLImageView()

    // MARK: Initialization

    /// :nodoc:
    convenience public init(placeholderImage: UIImage) {
        self.init(frame: CGRect.zero)
        self.placeholderImage = placeholderImage
        commonInit()
    }

    /// :nodoc:
    convenience public init(placeholderView: UIView) {
        self.init(frame: CGRect.zero)
        self.placeholderView = placeholderView
        commonInit()
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

    /// :nodoc:
    fileprivate func commonInit() {
        addSubview(imageView)
        imageView.delegate = self
    }

    // MARK: Manage Image Requests

    /// Cancels the current image load task
    open func cancelImageLoad() {
        imageView.cancelImageLoad()
    }

    // MARK: Layout

    open override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    // MARK: URLImageViewDelegate

    func loadedImage(image: UIImage?, error: Error?) {
        if let loadedImage = image {
            self.image = loadedImage
            placeholderView?.isHidden = true
        } else {
            placeholderView?.isHidden = false
        }
    }
}
