//
//  Logger.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/11.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

class Logger: NSObject {
    
    private static let sharedInstance = Logger()
    public var logRecordsArr: [String] = []
    
    public struct ElementOptions : OptionSet {
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static var None = ElementOptions(rawValue: 0 << 0);
        
        public static var CallStack = ElementOptions(rawValue: 1 << 1);
        public static var ThreadInfo = ElementOptions(rawValue: 1 << 2);

        public static var FileName = ElementOptions(rawValue: 1 << 3);
        public static var LineNum = ElementOptions(rawValue: 1 << 4);
        public static var ColumnNum = ElementOptions(rawValue: 1 << 5);
        public static var FunctionName = ElementOptions(rawValue: 1 << 6);

        public static var Default = ElementOptions(rawValue: ElementOptions.FileName.rawValue + ElementOptions.LineNum.rawValue + ElementOptions.FunctionName.rawValue);

        public static var All = ElementOptions(rawValue: UINTPTR_MAX);

    }
    
    override init() {
        super.init();
        
    }
    
    class func shared() -> Logger {
        return sharedInstance;
    }
    
    func appendAdditionInfo(elements: ElementOptions, file:String, function:String,
                            line:Int, originInfo: inout String) {
        
        if elements.contains(ElementOptions.FileName) {
            originInfo = originInfo + "file: " + file + "\n"
        }
        
        if elements.contains(ElementOptions.FunctionName) {
            originInfo = originInfo + "function: " + function + "\n"
        }

        if elements.contains(ElementOptions.LineNum) {
            originInfo = originInfo + "line: \(line)" + "\n"
        }

        if elements.contains(ElementOptions.CallStack) {
            let callStack = Thread.callStackSymbols;
            
            originInfo = originInfo + "CallTree: ["
            
            for call:String in  callStack {
                originInfo = originInfo + call + ",\n"
            }
            originInfo = originInfo + "]\n"
        }
        
        if elements.contains(ElementOptions.ThreadInfo) {
            let threadInfo = Thread.current.description;
            originInfo = originInfo + "ThreadInfo: " + threadInfo + "\n"
        }
    }
    
    public func log(_ items: Any..., file:String = #file, function:String = #function,
                    line:Int = #line) {
        log(items, file: file, function: function, line: line, elements: ElementOptions.Default)
    }
    
    public func log(_ items: Any..., file:String = #file, function:String = #function,
                    line:Int = #line, elements: ElementOptions) {
        
        
        var logInfo = "LogMessage = "
        
        
        print(items, to: &logInfo)
        appendAdditionInfo(elements: elements, file: file, function: function, line: line, originInfo: &logInfo)
        logRecordsArr.append(logInfo)
        print(logInfo);
    }
    
}

