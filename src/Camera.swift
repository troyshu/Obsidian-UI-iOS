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
    func cameraCaptureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    
    /// Delegates receive this message whenever a late video frame is dropped.
    func cameracaptureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
    
    /**
     This method is called after startRecording is called.
     
     - parameter movieURL: An NSURL where the recorded video is being saved. Movie will exist at this URL until startRecording is called again.
     
     */
    func cameraDidStartRecordingVideo(movieURL: NSURL)
    
    /**
     This method is called after stopRecording is called.
     
     - parameter movieURL: An NSURL where the recorded video has been saved. Movie will exist at this URL until startRecording is called again.
     
     */
    func cameraDidFinishRecordingVideo(movieURL: NSURL)
}

/**
 This class provides access to the device's cameras for still image and video capture.
 The camera can be configured to adjust focus and exposure.
 
 */
public class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    private var session = AVCaptureSession()
    private var sessionQueue = dispatch_queue_create("AlfredoCameraSession", DISPATCH_QUEUE_SERIAL)
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    private var currentCamera: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceinput: AVCaptureDeviceInput?
    private var stillImageOutput = AVCaptureStillImageOutput()
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var audioDataOutput: AVCaptureAudioDataOutput?
    private var captureConnection: AVCaptureConnection?
    private var useFrontCamera = false
    
    /// The delegate must conform to the CameraDelegate protocol.
    public var delegate: CameraDelegate?
    
    /// Add this layer to a view to get live camera preview
    public var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// How the camera focuses
    public var focusMode: AVCaptureFocusMode? {
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
    public var flashMode: AVCaptureFlashMode? {
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
    
    private func setupSession() {
        session.sessionPreset = sessionPreset
        
        session.beginConfiguration()
        addVideoInput()
        addVideoOutput()
        addStillImageOutput()
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.backgroundColor = UIColor.blackColor().CGColor
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        session.startRunning()
    }
    
    func tearDownSession() {
        previewLayer?.removeFromSuperlayer()
        session.stopRunning()
    }
    
    // MARK: Inputs & Outputs
    
    /// Checks device for front and back cameras
    public func hasFrontAndBackCameras() -> Bool {
        let hasFront = hasFrontCamera
        let hasBack = hasBackCamera
        
        if hasFront && hasBack {
            return true
        } else {
            return false
        }
    }
    
    /// Checks if the device has a camera at the front of the device, facing the user.
    public var hasFrontCamera: Bool {
        get {
            return frontCamera != nil
        }
    }
    
    /// Checks if the device has a camera at the back of the device, facing away from the user.
    public var hasBackCamera: Bool {
        get {
            return backCamera != nil
        }
    }
    
    private func addVideoInput() {
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if device.position == AVCaptureDevicePosition.Back {
                backCamera = device as? AVCaptureDevice
            } else if device.position == AVCaptureDevicePosition.Front {
                frontCamera = device as? AVCaptureDevice
            }
        }
        
        if !useFrontCamera {
            if backCamera == nil {
                backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            }
            currentCamera = backCamera
        } else {
            if frontCamera == nil {
                frontCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
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
        
        if let port = videoDeviceInput?.ports.first as? AVCaptureInputPort, preview = previewLayer {
            captureConnection = AVCaptureConnection(inputPort: port, videoPreviewLayer: preview)
        }
    }
    
    private func addAudioInput() {
        let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        let audioInput = try? AVCaptureDeviceInput(device: audioDevice)
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
    }
    
    private func addStillImageOutput() {
        stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    private func addVideoOutput() {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput!.alwaysDiscardsLateVideoFrames = true
        videoDataOutput!.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
    }
    
    private func addAudioOutput() {
        audioDataOutput = AVCaptureAudioDataOutput()
        
        if session.canAddOutput(audioDataOutput) {
            session.addOutput(audioDataOutput)
        }
    }
    
    private var movieFileOutput = AVCaptureMovieFileOutput()
    
    private func addMovieFileOutput() {
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
    public func focusTo(lensPosition: Float) {
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
    public func compensateExposure(exposureValue: Float) {
        // locked, auto, continuousAuto, custom
        currentCamera?.setExposureTargetBias(exposureValue, completionHandler: { (time: CMTime) -> Void in
            
        })
    }
    
    /// The exposure mode.
    public var exposureMode: AVCaptureExposureMode {
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
    public var exposureMeterOffset: Float {
        get {
            return currentCamera!.exposureTargetOffset
        }
    }
    
    /**
     Focus on a point in the image.
     
     - parameter point: The location in the image that the camera will focus on
     
     */
    public func focusAtPoint(point: CGPoint) {
        if let camera = currentCamera {
            if camera.focusPointOfInterestSupported {
                camera.focusPointOfInterest = point
            }
        }
    }
    
    /**
     Set exposure  on a point in the image.
     
     - parameter point: The location in the image that the camera will focus on
     
     */
    public func exposeAtPoint(point: CGPoint) {
        if let camera = currentCamera {
            if camera.exposurePointOfInterestSupported {
                camera.exposurePointOfInterest = point
            }
        }
    }
    
    /**
     Target the camera's focuse and exposure at a point
     
     - parameter point: Where the camera should target for focus and exposure values
     
     */
    public func focusAndExposeAtPoint(point: CGPoint) {
        focusAtPoint(point)
        exposeAtPoint(point)
    }
    
    /// Switches between front and back cameras.
    public func switchCamera() {
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
    public func zoom(magnification: Double) {
        captureConnection?.videoScaleAndCropFactor = CGFloat(magnification)
    }
    
    /// Captures an image from the camera and saves it to the photos library.
    public func captureImage() {
        captureImage(nil)
    }
    
    /**
     Captures and image from the camera.
     
     - parameter completion: called after an image is captured. If this is nil, the captured image will
     be saved to the photos library.
     
     */
    public func captureImage(completion: ((capturedImage: UIImage) -> Void)?) {
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (sampleBuffer, error) -> Void in
            if sampleBuffer != nil {
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let image = UIImage(data: data)
                if let capturedImage = image {
                    if let finishIt = completion {
                        finishIt(capturedImage: capturedImage)
                    } else {
                        Photos.saveImage(image!, completion: nil)
                    }
                }
            }
        })
    }
    
    private let outputPath = "\(NSTemporaryDirectory())output.mov"
    
    public func startRecording() {
        let outputURL = NSURL(fileURLWithPath: outputPath)
        
        let fileManager = NSFileManager()
        if fileManager.fileExistsAtPath(outputPath) {
            do {
                try fileManager.removeItemAtPath(outputPath)
            } catch {
                
            }
        }
        
        movieFileOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
    }
    
    public func stopRecording() {
        movieFileOutput.stopRecording()
    }
    
    // MARK: File Output Recording Delegate
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        delegate?.cameraDidFinishRecordingVideo(outputFileURL)
    }
    
    public func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        delegate?.cameraDidStartRecordingVideo(NSURL(fileURLWithPath: outputPath))
    }
    
    // MARK: Sample Buffer Delegate
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        delegate?.cameraCaptureOutput(captureOutput, didOutputSampleBuffer: sampleBuffer, fromConnection: connection)
    }
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        delegate?.cameracaptureOutput(captureOutput, didDropSampleBuffer: sampleBuffer, fromConnection: connection)
    }
    
}
