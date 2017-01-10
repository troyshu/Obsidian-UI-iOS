//
//  NSDateExtensions.swift
//  Alfredo
//
//  Created by Nick Lee on 8/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public extension Date {

    // MARK: Formatting

    /// Returns the receiver represented as a short string (e.g. '30s', '4h', '1d')
    public var timeAgo: String {

        let date = self

        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second]
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (now as NSDate).laterDate(date)
        let components = (calendar as NSCalendar).components(unitFlags, from: earliest, to: latest, options: [])

        if components.year! >= 2 {
            return "\(components.year)y"
        } else if components.year! >= 1 {
            return "1y"
        } else if components.month! >= 2 {
            return "\(components.month! * 4)w"
        } else if components.month! >= 1 {
            return "4w"
        } else if components.weekOfYear! >= 2 {
            return "\(components.weekOfYear)w"
        } else if components.weekOfYear! >= 1 {
            return "1w"
        } else if components.day! >= 2 {
            return "\(components.day)d"
        } else if components.day! >= 1 {
            return "1d"
        } else if components.hour! >= 2 {
            return "\(components.hour)h"
        } else if components.hour! >= 1 {
            return "1h"
        } else if components.minute! >= 2 {
            return "\(components.minute)m"
        } else if components.minute! >= 1 {
            return "1m"
        } else {
            return "\(components.second)s"
        }
    }
}
