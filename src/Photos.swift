//
//  Photos.swift
//  Alfredo
//
//  Created by Eric Kunz on 8/17/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import Photos

/**
 This class manages photo library assets.
 Adding and retreiving photos happens on an arbitrary serial queue. Dispatch calls to the maine queue to update the app's UI as a result of a change.
 */
public class Photos {
    
    public typealias Completion = ((Bool, NSError?) -> Void)?
    public typealias ImageCompletion = ((UIImage?) -> Void)?
    
    private func performChanges(changeBlock: dispatch_block_t, completionHandler: ((Bool, NSError?) -> Void)!) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges(changeBlock, completionHandler: completionHandler)
    }
    
    private func performChanges(changeBlock: dispatch_block_t) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges(changeBlock, completionHandler: nil)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter completion: called after image is saved
     
     */
    public func saveImage(image: UIImage, completion: Completion = nil) {
        performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of an image to be saved
     - parameter completion: Called after the image is saved
     
     */
    public func saveImage(URL: NSURL, completion: Completion = nil) {
        performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(URL)
            }, completionHandler: completion)
    }
    
    private func createAssetCollection(name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: fetchOptions)
        var alreadyExists = false
        for var i = 0; i < fetchResult.count; ++i {
            if let collection = fetchResult[i] as? PHAssetCollection {
                if collection.localizedTitle == name {
                    alreadyExists = true
                    return collection
                }
            }
        }
        
        var assetCollection: PHAssetCollection?
        if !alreadyExists {
            performChanges({ () -> Void in
                PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(name)
                
                }, completionHandler: { (success, error) -> Void in
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([name], options: nil)
                    assetCollection =  collectionFetchResult.firstObject as? PHAssetCollection
            })
        }
        
        return assetCollection
    }
    
    /**
     Saves an image to the photos library
     
     - parameter image: The image to be saved
     - parameter albumName: The name of the album to save to
     - parameter completion: Called after the image is saved
     
     */
    public func saveImageToAlbum(image: UIImage, albumName: String, completion: Completion) {
        let assetCollection = createAssetCollection(albumName)
        
        performChanges({ () -> Void in
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection!)
            let enumeration: NSArray = [assetPlaceholder!]
            albumRequest!.addAssets(enumeration)
            }, completionHandler: completion)
    }
    
    /**
     Saves an image to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter ocmpletion: Called after the video is saved
     
     */
    public func saveVideo(URL: NSURL, completion: Completion = nil) {
        performChanges({ () -> Void in
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(URL)
            }, completionHandler: completion)
    }
    
    /**
     Saves a video to the photos library
     
     - parameter URL: The url of a video to be saved
     - parameter albumName: The name of the album to save to
     
     */
    public func saveVideoToAlbum(URL: NSURL, albumName: String, completion: Completion) {
        let assetCollection = createAssetCollection(albumName)
        
        performChanges { () -> Void in
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(URL)
            let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
            let albumRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection!)
            let enumeration: NSArray = [assetPlaceholder!]
            albumRequest?.addAssets(enumeration)
            
        }
    }
    
    /**
     Gets the most recently created asset in the photo library
     
     - parameter size: The size the image will be returned in
     - parameter contentMode: How the image will fit into the size parameter
     
     */
    public func latestAsset(size: CGSize, contentMode: PHImageContentMode, completion: ImageCompletion) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        
        guard let lastAsset = fetchResult.lastObject as? PHAsset else {
            completion?(nil)
            return
        }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = PHImageRequestOptionsVersion.Current
        
        PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: size, contentMode: contentMode, options: requestOptions) { (image: UIImage?, dictionary: [NSObject : AnyObject]?) -> Void in
            completion?(image)
        }
        
    }
    
}
