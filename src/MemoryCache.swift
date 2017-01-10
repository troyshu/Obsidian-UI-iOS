//
//  MemoryCache.swift
//  Alfredo
//
//  Created by Nick Lee on 8/25/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public final class MemoryCache<K, T> where K: Hashable {

    // MARK: Public Properties

    /// The cache's identifier
    public let identifier: String

    /// The number of objects the cache is allowed to hold.  This limit is an estimate and is not interpreted strictly.
    public var countLimit: Int = 100 {
        didSet {
            prune()
        }
    }

    // MARK: Private Properties

    private var cache: [K : T] = [:]

    // MARK: Initialization

    /**
    Instantiates a new MemoryCache

    - parameter identifier: The cache's identifier

    - returns: A newly instantiated MemoryCache

    */
    public init(identifier: String) {
        self.identifier = identifier
    }

    // MARK: Cache Access

    /// Gets or sets the cached object for the passed key
    public subscript(key: K) -> T? {
        get {
            return cache[key]
        }
        set {
            if let v = newValue {
                prune()
                cache[key] = v
            } else {
                cache.removeValue(forKey: key)
            }
        }
    }

    /// Empties the cache.
    public func clear() {
        cache.removeAll()
    }

    // MARK: Pruning
    
    private func prune() {
        guard cache.count > countLimit else {
            return
        }
        while cache.count > countLimit, let key = cache.keys.first {
            cache.removeValue(forKey: key)
        }
    }

}
