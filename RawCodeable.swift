//
//  RawCodeable.swift
//  Prose
//
//  Created by Shawn Throop on 30/03/16.
//  Copyright © 2016 Silent H Designs. All rights reserved.
//

protocol RawCodeable: RawEncodeable, RawDecodeable {}

protocol RawEncodeable {
    func toRawValue() throws -> AnyObject
}

protocol RawDecodeable {
    static func fromRawValue(rawValue: AnyObject) throws -> Self
}



// MARK: EnumCodeable

protocol EnumCodeable: RawDecodeable, RawEncodeable, RawRepresentable {}

extension EnumCodeable {
    func toRawValue() throws -> AnyObject {
        guard let value = self.rawValue as? AnyObject else {
            throw RawCodeableError.TransformFailed(value: self.rawValue, toType: AnyObject.self) }
        
        return value
    }
    
    static func fromRawValue(rawValue: AnyObject) throws -> Self {
        guard let value = rawValue as? RawValue else {
            throw RawCodeableError.InvalidType(actualType: rawValue.dynamicType, expectedType: RawValue.self) }
        
        guard let result = Self(rawValue: value) else {
            throw RawCodeableError.TransformFailed(value: value, toType: Self.self) }
        
        return result
    }
}



// MARK: CompatibleCodeable

protocol CompatibleCodeable: RawCodeable {}

extension String: CompatibleCodeable {}
extension Double: CompatibleCodeable {}
extension Float: CompatibleCodeable {}
extension Bool: CompatibleCodeable {}
extension Int: CompatibleCodeable {}


extension CompatibleCodeable {
    func toRawValue() throws -> AnyObject {
        guard let value = self as? AnyObject else {
            throw RawCodeableError.TransformFailed(value: self, toType: AnyObject.self) }
        
        return value
    }
    
    static func fromRawValue(rawValue: AnyObject) throws -> Self {
        guard let value = rawValue as? Self else {
            throw RawCodeableError.TransformFailed(value: rawValue, toType: Self.self) }
        
        return value
    }
}





// MARK: RawCodeableError

enum RawCodeableError: ErrorType {
    case TransformFailed(value: Any, toType: Any.Type)
    case InvalidType(actualType: Any.Type, expectedType: Any.Type)
}

extension RawCodeableError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .TransformFailed(value, toType):
            return "RawCodeableError: Failed transforming value: \(value) to type \(toType)"
        case let .InvalidType(actualType, expectedType):
            return "RawCodeableError: Invalid type. Got \(actualType) instead of \(expectedType)"
        }
    }
}