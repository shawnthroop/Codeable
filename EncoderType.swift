//
//  EncoderType.swift
//  Prose
//
//  Created by Shawn Throop on 30/03/16.
//  Copyright © 2016 Silent H Designs. All rights reserved.
//

protocol EncoderType: class {
    var encoded: EncodedObject { get set }
    
    init()
    
    // Root
    static func encodeRootObject<Object: Encodeable>(object: Object) throws -> EncodedObject
    static func encodeRootObject<Object: Encodeable>(object: [Object]) throws -> [EncodedObject]
    
    // RawEncodeable
    func encode<Raw: RawEncodeable>(object: Raw, key: String) throws
    func encode<Raw: RawEncodeable>(object: Raw?, key: String) throws
    func encode<Raw: RawEncodeable>(object: [Raw], key: String) throws
    func encode<Raw: RawEncodeable>(object: [Raw]?, key: String) throws
    func encode<Raw: RawEncodeable>(object: [String: Raw], key: String) throws
    func encode<Raw: RawEncodeable>(object: [String: Raw]?, key: String) throws
    
    // Encodeable
    func encode<Object: Encodeable>(object: Object, key: String) throws
    func encode<Object: Encodeable>(object: Object?, key: String) throws
    func encode<Object: Encodeable>(object: [Object], key: String) throws
    func encode<Object: Encodeable>(object: [Object]?, key: String) throws
    func encode<Object: Encodeable>(object: [String: Object], key: String) throws
    func encode<Object: Encodeable>(object: [String: Object]?, key: String) throws
}





// MARK: EncoderType Default Implementaion


extension EncoderType {
    
    // MARK: Root
    
    static func encodeRootObject<Object: Encodeable>(object: Object) throws -> EncodedObject {
        return try encodeObject(object)
    }
    
    static func encodeRootObject<Object: Encodeable>(object: [Object]) throws -> [EncodedObject] {
        return try object.map { try encodeObject($0) }
    }
    
    
    // MARK: RawCodeable
    
    func encode<Raw: RawEncodeable>(object: Raw, key: String) throws {
        encoded[key] = try object.toRawValue()
    }
    
    func encode<Raw: RawEncodeable>(object: Raw?, key: String) throws {
        if let rawValue = object {
            try encode(rawValue, key: key)
        }
    }
    
    
    // MARK: [RawCodeable]
    
    func encode<Raw: RawEncodeable>(object: [Raw], key: String) throws {
        encoded[key] = try object.map { try $0.toRawValue() }
    }
    
    func encode<Raw: RawEncodeable>(object: [Raw]?, key: String) throws {
        if let object = object {
            try encode(object, key: key)
        }
    }
    
    
    // MARK: [String: RawCodeable]
    
    func encode<Raw: RawEncodeable>(object: [String: Raw], key: String) throws {
        var rawElements: [String: AnyObject] = [:]
        try object.forEach { rawElements[$0] = try $1.toRawValue() }
        encoded[key] = rawElements
    }
    
    func encode<Raw: RawEncodeable>(object: [String: Raw]?, key: String) throws {
        if let rawElements = object {
            try encode(rawElements, key: key)
        }
    }
    
    
    
    // MARK: Encodeable
    
    func encode<Object: Encodeable>(object: Object, key: String) throws {
        encoded[key] = try Self.encodeObject(object)
    }
    
    func encode<Object: Encodeable>(object: Object?, key: String) throws {
        if let object = object {
            try encode(object, key: key)
        }
    }
    
    
    // MARK: [Encodeable]
    
    func encode<Object: Encodeable>(object: [Object], key: String) throws {
        encoded[key] = try object.map { try Self.encodeObject($0) }
    }
    
    func encode<Object: Encodeable>(object: [Object]?, key: String) throws {
        if let objects = object {
            try encode(objects, key: key)
        }
    }
    
    
    // MARK: [String: Encodeable]
    
    func encode<Object: Encodeable>(object: [String: Object], key: String) throws {
        var elements: [String: EncodedObject] = [:]
        try object.forEach { elements[$0] = try Self.encodeObject($1) }
        encoded[key] = elements
    }
    
    func encode<Object: Encodeable>(object: [String: Object]?, key: String) throws {
        if let elements = object {
            try encode(elements, key: key)
        }
    }
    
    
    // MARK: Private
    
    private static func encodeObject<Object: Encodeable>(object: Object) throws -> EncodedObject {
        let encoder = Self()
        try object.encode(encoder)
        return encoder.encoded
    }
}

