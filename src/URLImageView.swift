//
//  URLImageView.swift
//  Alfredo
//
//  Created by Nick Lee on 8/25/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

protocol URLImageViewDelegate {
    func loadedImage(image: UIImage?, error: Error?)
}

public final class URLImageView: UIImageView {

    // MARK: Properties

    /// The URL of the image displayed in the view
    public var imageURL: URL? {
        didSet {
            if imageURL == nil {
                cancelImageLoad()
                image = nil
            } else {
                loadImage()
            }
        }
    }

    var delegate: URLImageViewDelegate?

    // MARK: Private Properties

    fileprivate var task: ImageDownloadTask?
    fileprivate var cancelled = false

    // MARK: Initialization

    /// :nodoc:
    convenience public init() {
        self.init(frame: CGRect.zero)
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// :nodoc:
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: Managing image requests

    fileprivate func loadImage() {

        cancelImageLoad()

        cancelled = false

        if let url = imageURL {
            task = ImageDownloader.sharedInstance.download(url, completion: { [weak self] (image, error) -> () in

                if let cancelled = self?.cancelled, !cancelled {
                    self?.image = image
                    self?.delegate?.loadedImage(image: image, error: error)
                }

                self?.task = nil

                })
        }

    }

    /// Cancels the current image load task
    public func cancelImageLoad() {
        cancelled = true
        task?.cancel()
        task = nil
    }

}
