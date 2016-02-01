//
//  UIImageExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import UIKit

public extension UIImage {

    // MARK: UI Helpers

    /// Returns a UIImageView with its bounds and contents pre-populated by the receiver
    public var imageView: UIImageView {
        let bounds = CGRect(origin: CGPoint.zero, size: size)
        let view = UIImageView(frame: bounds)
        view.image = self
        view.contentMode = .Center
        return view
    }

}

internal extension UIImage {

    internal func decodedImage() -> UIImage? {
        return decodedImage(scale: scale)
    }

    internal func decodedImage(scale scale: CGFloat) -> UIImage? {

        let imageRef = CGImage

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)

        let context = CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, bitmapInfo.rawValue)

        if let context = context {
            let rect = CGRect(0, 0, CGFloat(CGImageGetWidth(imageRef)), CGFloat(CGImageGetHeight(imageRef)))
            CGContextDrawImage(context, rect, imageRef)
            let decompressedImageRef = CGBitmapContextCreateImage(context)
            if let decompressed = decompressedImageRef {
                return UIImage(CGImage: decompressed, scale: scale, orientation: imageOrientation)
            }
        }

        return nil

    }

}
