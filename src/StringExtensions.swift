//
//  StringExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/26/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension String {

    /// Generates an NSURL from the receiver, if possible.
    public var URL: Foundation.URL? {
        return Foundation.URL(string: self)
    }

    /// The number of individual, composed character sequences
    public var length: Int { return characters.count }

    // Returns the character at index i
    public subscript(i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }

    /// Removes the end character from the String
    public mutating func removeLastCharacter() { removeCharactersFromEnd(1) }

    /**
    Removes a number of characters from the end of the String.

    - parameter removeThisMany: The number of characters to remove from the end of the String.

    */
    public mutating func removeCharactersFromEnd(_ removeThisMany: Int) {
        
        guard length > removeThisMany else {
            self = ""
            return
        }
        
        var end = endIndex
        
        for _ in 0 ..< removeThisMany {
            end = index(before: end)
        }
        
        self = substring(to: end)
    }

    /// Removes the first character from the String.
    public mutating func removeFirstCharacter() { removeCharactersFromStart(1) }

    /**
    Removes a number of characters from the start of the String.

    - Parameter removeThisMany: The number of characters to remove from the start of the String.

    */
    public mutating func removeCharactersFromStart(_ removeThisMany: Int) {
        
        guard length > removeThisMany else {
            self = ""
            return
        }
        
        var start = startIndex
        
        for _ in 0 ..< removeThisMany {
            start = index(after: start)
        }
        
        self = substring(from: start)
    }
}
