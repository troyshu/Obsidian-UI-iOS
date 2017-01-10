//
//  Camera.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/17/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import AVFoundation

public protocol CameraDelegate {

    /// Delegates receive this message whenever the camera captures and outputs a new video frame.
    func cameraCaptureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)

    /// Delegates receive this message whenever a late video frame is dropped.
    func cameracaptureOutput(_ captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)

    /**
     This method is called after startRecording is called.

     - parameter movieURL: An NSURL where the recorded video is being saved. Movie will exist at this URL until startRecording is called again.

     */
    func cameraDidStartRecordingVideo(_ movieURL: URL)

    /**
     This method is called after stopRecording is called.

     - parameter movieURL: An NSURL where the recorded video has been saved. Movie will exist at this URL until startRecording is called again.

     */
    func cameraDidFinishRecordingVideo(_ movieURL: URL)
}

/**
 This class provides access to the device's cameras for still image and video capture.
 The camera can be configured to adjust focus and exposure.

 */
open class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {

    fileprivate var session = AVCaptureSession()
    fileprivate var sessionQueue = DispatchQueue(label: "AlfredoCameraSession", attributes: [])
    fileprivate var frontCamera: AVCaptureDevice?
    fileprivate var backCamera: AVCaptureDevice?
    fileprivate var currentCamera: AVCaptureDevice?
    fileprivate var videoDeviceInput: AVCaptureDeviceInput?
    fileprivate var audioDeviceinput: AVCaptureDeviceInput?
    fileprivate var stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var videoDataOutput: AVCaptureVideoDataOutput?
    fileprivate var audioDataOutput: AVCaptureAudioDataOutput?
    fileprivate var captureConnection: AVCaptureConnection?
    fileprivate var useFrontCamera = false

    /// The delegate must conform to the CameraDelegate protocol.
    open var delegate: CameraDelegate?

    /// Add this layer to a view to get live camera preview
    open var previewLayer: AVCaptureVideoPreviewLayer?

    /// How the camera focuses
    open var focusMode: AVCaptureFocusMode? {
        get {
            return currentCamera?.focusMode
        }
        set {
            if let value = newValue {
                currentCamera?.focusMode = value
            }
        }
    }

    /// How the flash fires. Default is off.
    open var flashMode: AVCaptureFlashMode? {
        get {
            return currentCamera?.flashMode
        }
        set {
            if let value = newValue {
                currentCamera?.flashMode = value
            }
        }
    }

    /// The quality of image.
    var sessionPreset = AVCaptureSessionPresetPhoto

    public init(useFrontCamera: Bool = false, sessionPreset: String = AVCaptureSessionPresetiFrame1280x720) {
        super.init()
        self.sessionPreset = sessionPreset
        self.useFrontCamera = useFrontCamera
        setupSession()
    }

    // MARK: Session

    fileprivate func setupSession() {
        session.sessionPreset = sessionPreset

        session.beginConfiguration()
        addVideoInput()
        addVideoOutput()
        addStillImageOutput()
        session.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.backgroundColor = UIColor.black.cgColor
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

        session.startRunning()
    }

    func tearDownSession() {
        previewLayer?.removeFromSuperlayer()
        session.stopRunning()
    }

    // MARK: Inputs & Outputs

    /// Checks device for front and back cameras
    open func hasFrontAndBackCameras() -> Bool {
        let hasFront = hasFrontCamera
        let hasBack = hasBackCamera

        if hasFront && hasBack {
            return true
        } else {
            return false
        }
    }

    /// Checks if the device has a camera at the front of the device, facing the user.
    open var hasFrontCamera: Bool {
        get {
            return frontCamera != nil
        }
    }

    /// Checks if the device has a camera at the back of the device, facing away from the user.
    open var hasBackCamera: Bool {
        get {
            return backCamera != nil
        }
    }

    fileprivate func addVideoInput() {
        for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
            if (device as AnyObject).position == AVCaptureDevicePosition.back {
                backCamera = device as? AVCaptureDevice
            } else if (device as AnyObject).position == AVCaptureDevicePosition.front {
                frontCamera = device as? AVCaptureDevice
            }
        }

        if !useFrontCamera {
            if backCamera == nil {
                backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            }
            currentCamera = backCamera
        } else {
            if frontCamera == nil {
                frontCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            }
            currentCamera = frontCamera
        }

        do {
            try videoDeviceInput = AVCaptureDeviceInput(device: currentCamera)
        } catch {

        }

        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        }

        if let port = videoDeviceInput?.ports.first as? AVCaptureInputPort, let preview = previewLayer {
            captureConnection = AVCaptureConnection(inputPort: port, videoPreviewLayer: preview)
        }
    }

    fileprivate func addAudioInput() {
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)

        let audioInput = try? AVCaptureDeviceInput(device: audioDevice)

        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
    }

    fileprivate func addStillImageOutput() {
        stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]

        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }

    fileprivate func addVideoOutput() {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput!.alwaysDiscardsLateVideoFrames = true
        videoDataOutput!.setSampleBufferDelegate(self, queue: sessionQueue)

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
    }

    fileprivate func addAudioOutput() {
        audioDataOutput = AVCaptureAudioDataOutput()

        if session.canAddOutput(audioDataOutput) {
            session.addOutput(audioDataOutput)
        }
    }

    fileprivate var movieFileOutput = AVCaptureMovieFileOutput()

    fileprivate func addMovieFileOutput() {
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
    }

    // MARK: Control Camera

    /**
    Controls the lens position of the camera. Setting this switches the camera to manual focus mode.
    Call changeFocusMode(mode: FocusMode) to return to automatic focusing or other setting.

    - parameter focusDistance: A value between 0 and 1 (near and far) to adjust focus

    */
    open func focusTo(_ lensPosition: Float) {
        if let device = currentCamera {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(lensPosition, completionHandler: { (time: CMTime) -> Void in
                    device.unlockForConfiguration()
                })
            } catch {  }
        }
    }

    /**
     Underexpose or overexpose the image. This will affect both
     When exposureMode is AVCaptureExposureModeAutoExpose or AVCaptureExposureModeLocked, the bias will affect both metering and the actual exposure.
     When exposureMode is AVCaptureExposureModeCustom, it will only affect metering.

     - parameter exposureValue: A bias applied to the target exposure value.

     */
    open func compensateExposure(_ exposureValue: Float) {
        // locked, auto, continuousAuto, custom
        currentCamera?.setExposureTargetBias(exposureValue, completionHandler: { (time: CMTime) -> Void in

        })
    }

    /// The exposure mode.
    open var exposureMode: AVCaptureExposureMode {
        get {
            return currentCamera!.exposureMode
        }
        set {
            do {
                try currentCamera?.lockForConfiguration()
                currentCamera?.exposureMode = newValue
                currentCamera?.unlockForConfiguration()
            } catch {

            }
        }
    }

    /// The exposure level's offset from the target exposure value, in EV units
    open var exposureMeterOffset: Float {
        get {
            return currentCamera!.exposureTargetOffset
        }
    }

    /**
     Focus on a point in the image.

     - parameter point: The location in the image that the camera will focus on

     */
    open func focusAtPoint(_ point: CGPoint) {
        if let camera = currentCamera {
            if camera.isFocusPointOfInterestSupported {
                camera.focusPointOfInterest = point
            }
        }
    }

    /**
     Set exposure  on a point in the image.

     - parameter point: The location in the image that the camera will focus on

     */
    open func exposeAtPoint(_ point: CGPoint) {
        if let camera = currentCamera {
            if camera.isExposurePointOfInterestSupported {
                camera.exposurePointOfInterest = point
            }
        }
    }

    /**
     Target the camera's focuse and exposure at a point

     - parameter point: Where the camera should target for focus and exposure values

     */
    open func focusAndExposeAtPoint(_ point: CGPoint) {
        focusAtPoint(point)
        exposeAtPoint(point)
    }

    /// Switches between front and back cameras.
    open func switchCamera() {
        useFrontCamera = !useFrontCamera
        session.beginConfiguration()
        session.removeInput(videoDeviceInput)
        addVideoInput()
        session.commitConfiguration()
    }

    /**
     Magnifies the camera's image for preview and for the output image.

     - parameter magnification: The level of magification

     */
    open func zoom(_ magnification: Double) {
        captureConnection?.videoScaleAndCropFactor = CGFloat(magnification)
    }

    /// Captures an image from the camera and saves it to the photos library.
    open func captureImage() {
        captureImage(nil)
    }

    /**
     Captures and image from the camera.

     - parameter completion: called after an image is captured. If this nil, the captured image will
     be saved to the photos library.

     */
    open func captureImage(_ completion: ((_ capturedImage: UIImage) -> Void)?) {
        stillImageOutput.captureStillImageAsynchronously(from: stillImageOutput.connection(withMediaType: AVMediaTypeVideo), completionHandler: { (sampleBuffer, error) -> Void in
            if sampleBuffer != nil {

                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: data!)
                if let capturedImage = image {
                    if let finishIt = completion {
                        finishIt(capturedImage)
                    } else {
                        Photos().saveImage(image!, completion: nil)
                    }
                }
            }
        })
    }

    fileprivate let outputPath = "\(NSTemporaryDirectory())output.mov"

    open func startRecording() {
        let outputURL = URL(fileURLWithPath: outputPath)

        let fileManager = FileManager()
        if fileManager.fileExists(atPath: outputPath) {
            do {
                try fileManager.removeItem(atPath: outputPath)
            } catch {

            }
        }

        movieFileOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
    }

    open func stopRecording() {
        movieFileOutput.stopRecording()
    }

    // MARK: File Output Recording Delegate

    open func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        delegate?.cameraDidFinishRecordingVideo(outputFileURL)
    }

    open func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        delegate?.cameraDidStartRecordingVideo(URL(fileURLWithPath: outputPath))
    }

    // MARK: Sample Buffer Delegate

    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

        delegate?.cameraCaptureOutput(captureOutput, didOutputSampleBuffer: sampleBuffer, fromConnection: connection)
    }

    open func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

        delegate?.cameracaptureOutput(captureOutput, didDropSampleBuffer: sampleBuffer, fromConnection: connection)
    }

}
