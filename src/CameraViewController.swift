//
//  AFLCameraViewController.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/13/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import MobileCoreServices

protocol ALFCameraViewControllerDelegate {

    /// Tells the delegate that the close button was tapped.
    func didCancelImageCapture(_ cameraController: ALFCameraViewController)

    /// Tells the delegate that an image has been selected.
    func cameraControllerDidSelectImage(_ camera: ALFCameraViewController, image: UIImage)
}

/**
 Provides a camera for still image capture. Customizaton is available for the capture
 button (captureButton), flash control button (flashButton), resolution (sessionPreset),
 and which camera to use (devicePosition).

 After an image is captured the user is presented with buttons to accept or reject the photo.

 */
class ALFCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /**
     The delegate of a AFLCameraViewController must adopt the AFLCameraViewControllerDelegate protocol.
     Methods of the protocol allow the delegate to respond to an image selection or cancellation.
     */
    var delegate: ALFCameraViewControllerDelegate?

    fileprivate var camera: Camera

    ///Flash firing control. false by defualt.
    var flashOn = false

    /// The resolution to set the camera to.
    var sessionPreset = AVCaptureSessionPreset640x480

    /// Determines if image is saved to photo library on capture. Default is false.
    var savesToPhotoLibrary = false

    /// The tint color of the photo library picker's navigation bar
    var pickerNavigationBarTintColor = UIColor.white

    /// The button that is pressed to capture an image.
    @IBOutlet weak var captureButton: UIButton?

    /// The button that determines whether the flash fires while capturing an image.
    @IBOutlet weak var flashButton: UIButton?

    /// The view for live camera preview
    @IBOutlet weak var cameraPreview: UIView?

    /// Where the camera capture animation happens
    @IBOutlet weak var flashView: UIView?

    /// View for image review post image capture
    @IBOutlet weak fileprivate var capturedImageReview: UIImageView?

    /// User taps this to pass photo to delegate
    @IBOutlet weak var acceptButton: UIButton?

    /// Tapping this returns the user to capturing an image.
    @IBOutlet weak var rejectButton: UIButton?

    /// A button that dismisses the camera.
    @IBOutlet weak var exitButton: UIButton?

    /// Title at the top of the view.
    @IBOutlet weak var titleLabel: UILabel?

    /// A Label shown after image capture -
    /// e.g. Would you like to use this photo? or. May I take your hat, sir?
    @IBOutlet weak var questionLabel: UILabel?

    /// An instruction label below the camera preview
    @IBOutlet weak var hintDescriptionLabel: UILabel?

    /// Opens the photo library
    @IBOutlet weak var photoLibraryButton: UIButton?

    fileprivate var capturedImage: UIImage?
    fileprivate var inputCameraConnection: AVCaptureConnection?

    init(useFrontCamera: Bool) {
        camera = Camera(useFrontCamera: useFrontCamera, sessionPreset: sessionPreset)
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        flashButton?.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        teardownSession()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    fileprivate func teardownSession() {
        camera.tearDownSession()
    }

    // MARK: Actions

    fileprivate func showAcceptOrRejectView(_ show: Bool) {
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.captureButton?.isHidden = show
            self.flashButton?.isHidden = show
            self.cameraPreview?.isHidden = show

            self.capturedImageReview?.isHidden = !show
            self.acceptButton?.isHidden = !show
            self.rejectButton?.isHidden = !show
        })
    }

    fileprivate func didPressAcceptPhotoButton() {
        delegate?.cameraControllerDidSelectImage(self, image: capturedImage!)
        teardownSession()
    }

    fileprivate func didPressRejectPhotoButton() {
        capturedImage = nil
        showAcceptOrRejectView(false)
    }

    fileprivate func didPressExitButton() {
        delegate?.didCancelImageCapture(self)
        teardownSession()
    }

    fileprivate func takePicture() {
        camera.captureImage { (capturedImage) -> Void in
            self.displayCapturedImage(capturedImage)
        }
    }

    fileprivate func displayCapturedImage(_ image: UIImage) {
        capturedImageReview?.image = image
        showAcceptOrRejectView(true)
    }

    fileprivate func flashCamera() {
        let key = "opacity"
        let flash = CABasicAnimation(keyPath: key)
        flash.fromValue = 0
        flash.toValue = 1
        flash.autoreverses = true
        flash.isRemovedOnCompletion = true
        flash.duration = 0.15
        flashView?.layer.add(flash, forKey: key)
    }

    // MARK: Photo Library

    fileprivate func didTapPhotoLibraryButton() {
        presentPhotoLibraryPicker()
    }

    fileprivate func loadPhotoLibraryPreviewImage() {
        if let libraryButton = photoLibraryButton {
            Photos().latestAsset(libraryButton.frame.size, contentMode: .aspectFill, completion: { (image: UIImage?) -> Void in
                libraryButton.imageView?.image = image
            })
        }
    }

    fileprivate func configurePhotoLibraryButtonForNoAccess() {
        photoLibraryButton?.backgroundColor = UIColor.black
    }

    fileprivate func presentPhotoLibraryPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        // let availableTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        imagePicker.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        imagePicker.navigationBar.barTintColor = pickerNavigationBarTintColor
        imagePicker.navigationBar.isTranslucent = false

        self.present(imagePicker, animated: true, completion: nil)
    }

    // MARK: Image Picker Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        dismiss(animated: true, completion: { () -> Void in
            self.capturedImage = image
            self.displayCapturedImage(image)
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: { () -> Void in
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        })
    }

    // MARK: Navigation Controller Delegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }

}
