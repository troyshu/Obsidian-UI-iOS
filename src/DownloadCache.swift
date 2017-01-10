//
//  DownloadCache.swift
//  Alfredo
//
//  Created by Nick Lee on 8/12/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import MobileCoreServices

public protocol Cacheable {

    /// An identifier for the cached item
    var identifier: String { get }

    /// The URL from which the data should be downloaded, and eventually cached
    var url: URL { get }

    /// The type of the file being downloaded from the URL.  If nil, uses the path extension from the URL instead.  See Apple's UTType Reference for more details.
    var fileType: CFString? { get }

}

private protocol DummySessionDelegate: class {
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL)
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?)
}

private class SessionDelegate: NSObject, URLSessionDownloadDelegate {

    fileprivate weak var delegate: DummySessionDelegate?

    @objc func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.URLSession(session, task: task, didCompleteWithError: error as NSError?)
    }

    @objc func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
    }

}

open class DownloadCache<T: Cacheable>: DummySessionDelegate {

    // MARK: Types

    /// :nodoc:
    public typealias Completion = (_ item: T) -> ()

    /// :nodoc:
    public typealias Failure = (_ item: T, _ error: NSError) -> ()

    // MARK: Properties

    /// The name of the cache.  This name will be used as the name of the directory in which the cached data is stored.
    open let name: String

    /// The closure that will be executed on successful item caching.
    open var itemCompletion: Completion?

    /// The closure that will be executed when caching fails for an item
    open var itemFailure: Failure?

    /// An read-only array representing the current items in the queue
    open var queue: [T] {
        var q: [T] = []

        queueMutex.perform {
            q += Array(self.tasks.map({ (k, v) -> (String, T) in
                return (k, v.item)
            }).values)
            return
        }

        return q
    }

    // MARK: Private Properties

    fileprivate var directory: String {
        let dir = NSString(string: NSString(string: Directories.cache).appendingPathComponent(UIApplication.shared.bundleIdentifier)).appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch _ {}
        return dir
    }

    fileprivate let sessionDelegate: SessionDelegate
    fileprivate let session: Foundation.URLSession
    fileprivate var queueMutex = MutexPool()
    fileprivate var tasks: [ String : (task: URLSessionDownloadTask, item: T) ] = [:]

    // MARK: Initialization

    /**
    Initializes and returns a newly allocated DownloadCache object with the specified name.

    - parameter name: The name of the cache.  This name will be used as the name of the directory in which the cached data is stored.
    - parameter configuration: The NSURLSessionConfiguration to use when instantiating the DownloadCache's internal NSURLSession.

    - returns: An initialized DownloadCache object

    */
    public init(name: String, configuration: URLSessionConfiguration) {
        self.name = name
        sessionDelegate = SessionDelegate()
        session = Foundation.URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        sessionDelegate.delegate = self
    }

    /**
    Initializes and returns a newly allocated DownloadCache object with the specified name.

    - parameter name: The name of the cache.  This name will be used as the name of the directory in which the cached data is stored.

    - returns: An initialized DownloadCache object

    */
    public convenience init(name: String) {
        self.init(name: name, configuration: URLSessionConfiguration.default)
    }

    // MARK: File Management

    fileprivate func path(_ item: Cacheable, part: Bool = false) -> String {

        var ext = item.url.pathExtension

        if let typeIdentifier = item.fileType, let typeExtension = UTTypeCopyPreferredTagWithClass(typeIdentifier, kUTTagClassFilenameExtension)?.takeUnretainedValue() as? String {
            ext = typeExtension
        }

        var filename = NSString(string: item.identifier)
        
        if !ext.isEmpty {
            let filenameWithExtension = filename.appendingPathExtension(ext) ?? ""
            filename = filenameWithExtension as NSString
        }

        if let filenameWithPartExtension = filename.appendingPathExtension("part"), part {
            filename = filenameWithPartExtension as NSString
        }

        return NSString(string: directory).appendingPathComponent(filename as String)

    }

    fileprivate func exists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    fileprivate func task(_ item: Cacheable) -> URLSessionDownloadTask? {

        let contentPath = path(item)
        let partPath = path(item, part: true)

        if exists(contentPath) {
            return nil
        } else if let partData = try? Data(contentsOf: URL(fileURLWithPath: partPath)), exists(partPath) {
            return session.downloadTask(withResumeData: partData)
        } else {
            return session.downloadTask(with: item.url)
        }

    }

    // MARK: Managing the Cache Queue

    /// Resumes any active downloads
    open func resume() {
        queueMutex.perform {
            let running = self.tasks.filter({ (key, val) -> Bool in
                let result = val.task.state == .running
                return result
            })
            if running.isEmpty {
                let stopped = self.tasks.filter({ (key, val) -> Bool in
                    let result = val.task.state == .suspended
                    return result
                })
                if let first = stopped.keys.first, let task = stopped[first]?.task {
                    task.resume()
                }
            }
        }
    }

    /// Pauses any active downloads
    open func pause() {
        queueMutex.perform {
            for (_, v) in self.tasks {
                if v.task.state == .running {
                    v.task.suspend()
                }
            }
        }
    }

    /**
    Enqueues an item.  Passing an item that has already been enqueued results in a no-op.

    - parameter item: The item (conforming to the Cacheable protocol) to enqueue.

    */
    open func enqueue(_ item: T) {
        queueMutex.perform {
            if let task = self.task(item) {
                if self.tasks[item.identifier] == nil {
                    self.tasks[item.identifier] = (task: task, item: item)
                }
            } else {
                DispatchQueue.main.async {
                    self.handleItemCompletion(item, error: nil)
                }
            }
        }
        resume()
    }

    /**
    Enqueues an array of items.  Items that have already been enqueued will be skipped.

    - parameter items: The array of items (conforming to the Cacheable protocol) to enqueue.

    */
    open func enqueue(_ items: [T]) {
        items.forEach(enqueue)
    }

    /**
    Dequeues an item.  Passing an item that is not in the queue results in a no-op.

    - parameter item: The item (conforming to the Cacheable protocol) to dequeue.

    */
    open func dequeue(_ item: T) {
        queueMutex.perform {
            if let entry = self.tasks[item.identifier] {

                if entry.task.state == .running {
                    let path = self.path(item, part: true)
                    entry.task.cancel { (data) -> Void in
                        try? data?.write(to: URL(fileURLWithPath: path), options: [.atomic])
                    }
                }

                self.tasks.removeValue(forKey: item.identifier)
            }
        }
    }

    /**
    Dequeues an array of items.  Items that are not in the queue will be skipped.

    - parameter items: The array of items (conforming to the Cacheable protocol) to dequeue.

    */
    open func dequeue(_ items: [T]) {
        items.forEach(dequeue)
    }

    /**
    Returns a file URL to the passed item

    - parameter item: The item to look up

    - returns:  An NSURL pointing to the cached item, or nil if it has not yet been cached

    */
    open func get(_ item: T) -> URL? {
        let filePath = path(item, part: false)
        if exists(filePath) {
            return URL(fileURLWithPath: filePath)
        } else {
            return nil
        }
    }

    // MARK: DummySessionDelegate

    fileprivate func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {

        queueMutex.perform {
            let matching = self.tasks.filter({ (key, val) -> Bool in
                return val.task == downloadTask
            })
            if let item = matching.values.first?.item {
                let path = location.path
                let toPath = self.path(item)
                do {
                    try FileManager.default.moveItem(atPath: path, toPath: toPath)
                } catch _ {}
            }
        }

        do {
            try FileManager.default.removeItem(at: location)
        } catch _ {}
        
    }

    fileprivate func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {

        queueMutex.perform {
            self.tasks = self.tasks.filter({ (key, val) -> Bool in
                let match = val.task == task

                if match {
                    DispatchQueue.main.async {
                        self.handleItemCompletion(val.item, error: error)
                    }
                }

                return !match
            })
        }

        resume()

    }

    // MARK: Notifications

    fileprivate func handleItemCompletion(_ item: T, error: NSError?) {
        if let e = error {
            self.itemFailure?(item, e)
        } else {
            self.itemCompletion?(item)
        }
    }

}
