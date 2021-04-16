//
//  Logger.swift
//  RCDataManager
//
//  Created by mac on 09.10.2020.
// 
import Foundation
//import Sentry

open class Logger {
    open class func verbose(_ message: @autoclosure () -> Any, _
                                file: String = #file,
                            _ function: String = #function,
                            line: Int = #line,
                            context: Any? = nil) {
        if let message = message() as? String {
           // SentrySDK.capture(message: message)
            print(message)
        }

    }

    /// log something which help during debugging (low priority)
    open class func debug(_ message: @autoclosure () -> Any, _
                            file: String = #file,
                          _ function: String = #function,
                          line: Int = #line,
                          context: Any? = nil) {
        if let message = message() as? String {
            //SentrySDK.capture(message: message)
            print(message)
        }
        if let message = message() as? Data {
            print(String(data: message, encoding: .utf8))
        }
    }
    
    open class func debugString(_ message: String) {
        print(message)
    }

    /// log something which you are really interested but which is not an issue or error (normal priority)
    open class func info(_ message: @autoclosure () -> Any, _
                            file: String = #file,
                         _ function: String = #function,
                         line: Int = #line,
                         context: Any? = nil) {
        if let message = message() as? String {
            //SentrySDK.capture(message: message)
            print(message)
        }

    }

    /// log something which may cause big trouble soon (high priority)
    open class func warning(_ message: @autoclosure () -> Any, _
                                file: String = #file,
                            _ function: String = #function,
                            line: Int = #line,
                            context: Any? = nil) {
        if let message = message() as? String {
            //SentrySDK.capture(message: message)
            print(message)
        }

    }

    /// log something which will keep you awake at night (highest priority)
    open class func error(_ message: @autoclosure () -> Any, _
                            file: String = #file,
                          _ function: String = #function,
                          line: Int = #line,
                          context: Any? = nil) {
        if let message = message() as? String {
          //  SentrySDK.capture(message: message)
            print(message)
        }
        
    }
}
