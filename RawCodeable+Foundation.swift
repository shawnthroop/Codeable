//
//  RawCodeable+Foundation.swift
//  Prose
//
//  Created by Shawn Throop on 30/03/16.
//  Copyright © 2016 Silent H Designs. All rights reserved.
//

import Foundation

extension NSURL: RawCodeable {
    func toRawValue() throws -> AnyObject {
        return self.absoluteString as AnyObject
    }
    
    static func fromRawValue(rawValue: AnyObject) throws -> Self {
        guard let value = rawValue as? String else {
            throw RawCodeableError.InvalidType(actualType: rawValue.dynamicType, expectedType: String.self) }
        
        guard let url = self.init(string: value) else {
            throw RawCodeableError.TransformFailed(value: value, toType: NSURL.self) }
        
        return url
    }
}


extension NSDate: RawCodeable {
    func toRawValue() throws -> AnyObject {
        return self.timeIntervalSinceReferenceDate
    }
    
    static func fromRawValue(rawValue: AnyObject) throws -> Self {
        guard let value = rawValue as? Double else {
            throw RawCodeableError.InvalidType(actualType: rawValue.dynamicType, expectedType: Double.self) }
        
        return self.init(timeIntervalSinceReferenceDate: value)
    }
}
