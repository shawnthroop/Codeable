//
//  DecoderType.swift
//  Prose
//
//  Created by Shawn Throop on 30/03/16.
//  Copyright © 2016 Silent H Designs. All rights reserved.
//

protocol DecoderType: class {
    var encoded: EncodedObject { get }
    
    init(encoded: EncodedObject)
    
    // Root
    static func decodeRootObject<Object: Decodeable>(object: AnyObject) throws -> Object
    static func decodeRootObject<Object: Decodeable>(object: AnyObject) throws -> [Object]
    
    // RawDecodeable
    func decode<Raw: RawDecodeable>(key: String) throws -> Raw
    func decode<Raw: RawDecodeable>(key: String) throws -> Raw?
    func decode<Raw: RawDecodeable>(key: String) throws -> [Raw]
    func decode<Raw: RawDecodeable>(key: String) throws -> [Raw]?
    func decode<Raw: RawDecodeable>(key: String) throws -> [String: Raw]
    func decode<Raw: RawDecodeable>(key: String) throws -> [String: Raw]?
    
    // Decodeable
    func decode<Object: Decodeable>(key: String) throws -> Object
    func decode<Object: Decodeable>(key: String) throws -> Object?
    func decode<Object: Decodeable>(key: String) throws -> [Object]
    func decode<Object: Decodeable>(key: String) throws -> [Object]?
    func decode<Object: Decodeable>(key: String) throws -> [String: Object]
    func decode<Object: Decodeable>(key: String) throws -> [String: Object]?
}



// MARK: DecoderType Default Implementaion


extension DecoderType {
    
    // MARK: Root
    
    static func decodeRootObject<Object: Decodeable>(object: AnyObject) throws -> Object {
        guard let element = object as? EncodedObject else {
            throw DecoderTypeError.Incompatible(key: "n/a", elementType: object.dynamicType, expectedType: EncodedObject.self) }
        
        return try Object(decoder: Self(encoded: element))
    }
    
    static func decodeRootObject<Object: Decodeable>(object: AnyObject) throws -> [Object] {
        guard let elements = object as? [EncodedObject] else {
            throw DecoderTypeError.Incompatible(key: "n/a", elementType: object.dynamicType, expectedType: [EncodedObject].self) }
        
        return try elements.map { try Object(decoder: Self(encoded: $0)) }
    }
    
    // MARK: RawDecodeable
    
    func decode<Raw: RawDecodeable>(key: String) throws -> Raw {
        guard let value: Raw = try decode(key) else {
            throw DecoderTypeError.Missing(key: key) }
        
        return value
    }
    
    func decode<Raw: RawDecodeable>(key: String) throws -> Raw? {
        guard let some = encoded[key] else {
            return nil }
        
        return try Raw.fromRawValue(some)
    }
    
    
    // MARK: [RawDecodeable]
    
    func decode<Raw: RawDecodeable>(key: String) throws -> [Raw] {
        guard let values: [Raw] = try decode(key) else {
            throw DecoderTypeError.Missing(key: key) }
        
        return values
    }
    
    func decode<Raw: RawDecodeable>(key: String) throws -> [Raw]? {
        guard let some = encoded[key] else {
            return nil }
        
        guard let elements = some as? [AnyObject] else {
            throw DecoderTypeError.Incompatible(key: key, elementType: some.dynamicType, expectedType: Array<AnyObject>.self) }
        
        return try elements.map { try Raw.fromRawValue($0) }
    }
    
    
    // MARK: [String: RawDecodeable]
    
    func decode<Raw: RawDecodeable>(key: String) throws -> [String: Raw] {
        guard let values: [String: Raw] = try decode(key) else {
            throw DecoderTypeError.Missing(key: key) }
        
        return values
    }
    
    func decode<Raw: RawDecodeable>(key: String) throws -> [String: Raw]? {
        guard let some = encoded[key] else {
            return nil }
        
        guard let elements = some as? [String: AnyObject] else {
            throw DecoderTypeError.Incompatible(key: key, elementType: some.dynamicType, expectedType: AnyObject.self) }
        
        var values = [String: Raw]()
        try elements.forEach { values[$0] = try Raw.fromRawValue($1) }
        
        return values
    }
    
    
    // MARK: Decodeable
    
    func decode<Object: Decodeable>(key: String) throws -> Object {
        guard let value: Object = try decode(key) else {
            throw DecoderTypeError.Missing(key: key) }
        
        return value
    }
    
    func decode<Object: Decodeable>(key: String) throws -> Object? {
        guard let some = encoded[key] else {
            return nil }
        
        guard let value = some as? EncodedObject else {
            throw DecoderTypeError.Incompatible(key: key, elementType: some.dynamicType, expectedType: EncodedObject.self) }
        
        let decoder = Self(encoded: value)
        
        return try Object(decoder: decoder)
    }
    
    
    // MARK: [Decodeable]
    
    func decode<Object: Decodeable>(key: String) throws -> [Object] {
        guard let values: [Object] = try decode(key) else {
            throw DecoderTypeError.Missing(key: key) }
        
        return values
    }
    
    func decode<Object: Decodeable>(key: String) throws -> [Object]? {
        guard let some = encoded[key] else {
            return nil }
        
        guard let elements = some as? [EncodedObject] else {
            throw DecoderTypeError.Incompatible(key: key, elementType: some.dynamicType, expectedType: [EncodedObject].self) }
        
        return try elements.map { try Object(decoder: Self(encoded: $0)) }
    }
    
    
    // MARK: [String: Decodeable]
    
    func decode<Object: Decodeable>(key: String) throws -> [String: Object] {
        guard let values: [String: Object] = try decode(key) else {
            throw DecoderTypeError.Missing(key: key) }
        
        return values
    }
    
    func decode<Object: Decodeable>(key: String) throws -> [String: Object]? {
        guard let some = encoded[key] else {
            return nil }
        
        guard let elements = some as? [String: EncodedObject] else {
            throw DecoderTypeError.Incompatible(key: key, elementType: some.dynamicType, expectedType: [String: EncodedObject].self) }
        
        var values = [String: Object]()
        try elements.forEach { values[$0] = try Object(decoder: Self(encoded: $1)) }
        
        return values
    }
}



// MARK: DecoderTypeError

enum DecoderTypeError: ErrorType {
    case Missing(key: String)
    case Incompatible(key: String, elementType: Any.Type, expectedType: Any.Type)
}

extension DecoderTypeError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .Missing(key):
            return "DecoderTypeError: Missing key: \(key)"
        case let .Incompatible(key, elementType, expectedType):
            return "DecoderTypeError: Incompatible type for key: \(key). Got \(elementType) instead of \(expectedType)"
        }
    }
}


