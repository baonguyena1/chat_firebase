//
//  Logger.swift
//  Jalan
//
//  Created by Bao Nguyen on 10/16/19.
//  Copyright © 2019 Mobilityx. All rights reserved.
//

import Foundation

enum LogEvent: String {
    case e = "[ERROR]" // error
    case i = "[INFO]" // info
    case d = "[DEBUG]" // debug
    case v = "[VERBOSE]" // verbose
    case w = "[WARNING]" // warning
    case s = "[SERVER]" // server
}

final class Logger {
    fileprivate static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    
    fileprivate static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    // Get file name
    fileprivate class func sourceFileName(_ filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    static func log(_ message: String = "",
                    event: LogEvent = .d,
                    fileName: String = #file,
                    line: Int = #line,
                    column: Int = #column,
                    funcName: String = #function) {
        #if DEBUG
        
        print("\(event.rawValue) \(Date().toString()) Main Thread: \(Thread.isMainThread) \(event.rawValue)[\(sourceFileName(fileName))]:\(line) \(column) \(funcName) : \(message)")
        #endif
    }
    
    static func error(_ mesage: String,
                         fileName: String = #file,
                         line: Int = #line,
                         column: Int = #column,
                         funcName: String = #function) {
        Logger.log(mesage, event: .e, fileName: fileName, line: line, column: column, funcName: funcName)
    }
}

private extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self)
    }
}
