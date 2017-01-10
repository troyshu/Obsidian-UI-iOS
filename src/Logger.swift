//
//  Logger.swift
//  Alfredo
//
//  Created by Nick Lee on 9/10/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation

public struct Logger {

    // MARK: Properties

    /// The date formatter used by the logger
    public static var dateFormatter: DateFormatter = {
        let defaultDateFormatter = DateFormatter()
        defaultDateFormatter.locale = Locale.current
        defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return defaultDateFormatter
        }()

    /// Whether or not the logger should print the date of the call
    public static var showDate = true

    /// Whether or not the logger should print the log level associated with the call
    public static var showLogLevel = true

    /// Whether or not the logger should print the name of the thread on which the logger was called
    public static var showThreadName = false

    /// Whether or not the logger should print the name of the calling function
    public static var showFileName = true

    /// Whether or not the logger should print the line number of the parent call
    public static var showLineNumber = true

    /// Whether or not the logger should print the name of the calling function
    public static var showFunctionName = true

    // MARK: Types

    internal enum LogLevel: Int, Comparable, CustomStringConvertible {

        case verbose
        case debug
        case info
        case warning
        case error
        case severe

        internal var description: String {
            switch self {
            case .verbose:
                return "Verbose"
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            case .severe:
                return "Severe"
            }
        }

    }

    // MARK: Internal Properties

    internal static let sharedInstance = Logger()

    // MARK: Logging

    /// Log the passed string at the verbose level
    public static func verbose(_ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        log(.verbose, date: Date(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the debug level
    public static func debug(_ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        log(.debug, date: Date(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the info level
    public static func info(_ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        log(.info, date: Date(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the warning level
    public static func warning(_ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        log(.warning, date: Date(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the error level
    public static func error(_ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        log(.error, date: Date(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    /// Log the passed string at the severe level
    public static func severe(_ closure: @autoclosure () -> String?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        log(.severe, date: Date(), logMessage: closure(), functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    internal static func log(_ level: LogLevel, date: Date, logMessage: String?, functionName: String, fileName: String, lineNumber: Int) {


        let threadName = "[" + (Thread.isMainThread ? "main" : (Thread.current.name != "" ? (Thread.current.name ?? "Unknown Thread") : String(format:"%p", Thread.current))) + "] "

        BackgroundQueue.async {

            var details = ""

            if self.showDate {
                details += self.dateFormatter.string(from: date) + " "
            }

            if self.showLogLevel {
                details += "[\(level)] "
            }

            if self.showThreadName {
                details += threadName
            }

            if self.showFileName {
                details += "[" + NSString(string: fileName).lastPathComponent + (self.showLineNumber ? ":" + String(lineNumber) : "") + "] "
            } else if self.showLineNumber {
                details += "[" + String(lineNumber) + "] "
            }

            if self.showFunctionName {
                details += "\(functionName) > "
            }

            if let message = logMessage {
                details += message
            }

            MainQueue.async {
                Swift.print(details)
            }

        }

    }

}

internal func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
