//
//  Permissions.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/14/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import AddressBook
import EventKit
import CoreLocation
import AVFoundation
import Photos

/// Easily acces the app's permissions to
open class Permissions {

    public enum PermissionStatus {
        case authorized, unauthorized, unknown, disabled
    }

    // MARK: Constants

    fileprivate let AskedForNotificationsDefaultsKey = "AskedForNotificationsDefaultsKey"

    // MARK: Managers

    lazy var locationManager = CLLocationManager()

    // MARK:- Permissions
    // MARK: Contacts

    /// The authorization status of access to the device's contacts.
    open func authorizationStatusContacts() -> PermissionStatus {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .authorized:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    open func askAuthorizationContacts() {
        switch authorizationStatusContacts() {
        case .unknown:
            ABAddressBookRequestAccessWithCompletion(nil, nil)
        default:
            break
        }
    }

    // MARK: Location Always

    /// The authorization status of access to the device's location at all times.
    open func authorizationStatusLocationAlways() -> PermissionStatus {
        if !CLLocationManager.locationServicesEnabled() {
            return .disabled
        }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .notDetermined, .authorizedWhenInUse:
            return .unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    open func askAuthorizationLocationAlways() -> Bool {
        switch authorizationStatusLocationAlways() {
        case .unknown:
            locationManager.requestAlwaysAuthorization()
            return true
        case .unauthorized, .authorized, .disabled:
            return false
        }
    }

    // MARK: Location While In Use

    /// The authorization status of access to the device's location.
    open func authorizationStatusLocationInUse() -> PermissionStatus {
        if !CLLocationManager.locationServicesEnabled() {
            return .disabled
        }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    open func askAuthorizationLocationInUse() -> Bool {
        switch authorizationStatusLocationAlways() {
        case .unknown:
            locationManager.requestAlwaysAuthorization()
            return true
        case .unauthorized, .authorized, .disabled:
            return false
        }
    }

    // MARK: Notifications

    /// The authorization status of the app receiving notifications.
    open func authorizationStatusNotifications() -> PermissionStatus {
        let settings = UIApplication.shared.currentUserNotificationSettings
        if settings?.types != UIUserNotificationType() {
            return .authorized
        } else {
            if UserDefaults.standard.bool(forKey: AskedForNotificationsDefaultsKey) {
                return .unauthorized
            } else {
                return .unknown
            }
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    open func askAuthorizationNotifications() -> Bool {
        switch authorizationStatusNotifications() {
        case .unknown:
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            return true
        case .unauthorized, .authorized, .disabled:
            return false
        }
    }

    // MARK: Photos

    /// The authorization status for access to the photo library.
    open func authorizationStatusPhotos() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    open func askAuthorizationStatusPhotos() -> Bool {
        let status = authorizationStatusPhotos()
        switch status {
        case .unknown:
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in

            }
            return true
        case .authorized, .disabled, .unauthorized:
            return false
        }
    }

    // MARK: Camera

    /// The authorization status for use of the camera.
    open func authorizationStatusCamera() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }

    /**
    Requests authorization by presenting the system alert. This will not present the alert and will return false if the
    authorization is unauthorized or already denied.

    - returns: Bool indicates if authorization was requested (true) or if it is not requested because it is
    already authorized, unauthorized, disabled (false).

    */
    open func askAuthorizationStatusCamera() -> Bool {
        let status = authorizationStatusCamera()
        switch status {
        case .unknown:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in

            })
            return true
        case .disabled, .unauthorized, .authorized:
            return false
        }
    }

    // MARK: System Settings

    /**
    Opens the app's system settings
    If the app has its own settings bundle they will be opened, else the main settings view will be presented.

    */
    open func openAppSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }

}
