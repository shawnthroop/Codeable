//
//  KeyedCoder.swift
//  Prose
//
//  Created by Shawn Throop on 30/03/16.
//  Copyright © 2016 Silent H Designs. All rights reserved.
//

class KeyedCoder: DecoderType, EncoderType {
    internal var encoded: EncodedObject
    
    // DecoderType
    required init(encoded: EncodedObject) {
        self.encoded = encoded
    }
    
    // EncoderType
    required init() {
        self.encoded = [:]
    }
}