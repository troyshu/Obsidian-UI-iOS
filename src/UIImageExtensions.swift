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
        view.contentMode = .center
        return view
    }

}

internal extension UIImage {

    internal func decodedImage() -> UIImage? {
        return decodedImage(scale: scale)
    }

    internal func decodedImage(scale: CGFloat) -> UIImage? {

        let imageRef = cgImage

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        let context = CGContext(data: nil, width: (imageRef?.width)!, height: (imageRef?.height)!, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        if let context = context {
            let rect = CGRect(0, 0, CGFloat((imageRef?.width)!), CGFloat((imageRef?.height)!))
            context.draw(imageRef!, in: rect)
            let decompressedImageRef = context.makeImage()
            if let decompressed = decompressedImageRef {
                return UIImage(cgImage: decompressed, scale: scale, orientation: imageOrientation)
            }
        }

        return nil

    }

}
