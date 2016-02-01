//
//  CameraView.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/24/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

@IBDesignable class CameraView: UIView {

    let topBarHeight = CGFloat(50)
    let captureButtonDimension = CGFloat(20)

    var closeButton: UIButton!
    var titleLabel: UILabel!
    var cameraPreview: UIView!
    var libraryButton: UIButton!
    var captureButton: UIButton!
    @IBInspectable var flashButton: UIButton!
    var switchCameraButton: UIButton!
    var imageReview: UIImageView!
//    var questionLabel: UILabel!
    var reviewContainerView: UIView!
//    var acceptButton: UIButton!
//    var rejectButtton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Use constraints to have buttons between bottom of frame and camera preview but no less than maybe 10 from the bottom

        backgroundColor = UIColor.blackColor()
        let rect = frame
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: Int(rect.width), height: Int(topBarHeight)))
        closeButton = CloseCross(frame: CGRect(x: 5, y: 5, width: topBarHeight - 5, height: topBarHeight - 5))
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rect.width, height: topBarHeight))
        titleLabel.text = "Camera"
        topBar.addSubview(closeButton)
        topBar.addSubview(titleLabel)
        addSubview(topBar)

        cameraPreview = UIView(frame: rect)
        cameraPreview.backgroundColor = UIColor.darkGrayColor()
        addSubview(cameraPreview)

        let bottomSpace = CGFloat(10)
        captureButton = CaptureButton(frame: CGRect(x: rect.width / 2 - captureButtonDimension, y: rect.height - (captureButtonDimension + bottomSpace), width: captureButtonDimension, height: captureButtonDimension))
        addSubview(captureButton)

        let sideButtonDimension = CGFloat(15)
        flashButton = UIButton(frame: CGRect(x: rect.width * 0.75 - sideButtonDimension / 2.0, y: rect.height - (sideButtonDimension + bottomSpace), width: sideButtonDimension, height: sideButtonDimension))
        addSubview(flashButton)

        libraryButton = UIButton(frame: CGRect(x: rect.width * 0.25 - sideButtonDimension, y: rect.height - (sideButtonDimension + bottomSpace), width: sideButtonDimension, height: sideButtonDimension))
        addSubview(libraryButton)

        imageReview = UIImageView(frame: cameraPreview.frame)
        imageReview.hidden = true
        addSubview(imageReview)

        reviewContainerView = UIView(frame: CGRect(x: 0, y: topBarHeight + rect.width, width: rect.width, height: rect.height - topBarHeight + rect.width))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class CloseCross: UIButton {
    @IBInspectable var color = UIColor.whiteColor()
    @IBInspectable var lineWidth = 5
    override func drawRect(rect: CGRect) {
        let pathOne = UIBezierPath()
        pathOne.moveToPoint(CGPoint(x: 0, y: 0))
        pathOne.addLineToPoint(CGPoint(x: rect.width, y: rect.height))
        pathOne.moveToPoint(CGPoint(x: rect.width, y: 0))
        pathOne.addLineToPoint(CGPoint(x: 0, y: rect.height))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = pathOne.CGPath
        shapeLayer.lineWidth = CGFloat(lineWidth)
        shapeLayer.fillColor = color.CGColor
    }
}

@IBDesignable class CaptureButton: UIButton {
    @IBInspectable var color = UIColor.clearColor()
    @IBInspectable var borderColor = UIColor.whiteColor()
    @IBInspectable var borderWidth = CGFloat(2)

    override func drawRect(rect: CGRect) {
        var buttonRect: CGRect

        if selected {
            buttonRect = CGRect(x: 0, y: 0, width: rect.size.width * 0.9, height: rect.size.height * 0.9)
        } else {
            buttonRect = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        }
        let button = UIView(frame: buttonRect)
        button.makeCircular()
        button.applyBorder(borderWidth, color: borderColor)
    }
}
