//
//  Codeable.swift
//  Prose
//
//  Created by Shawn Throop on 30/03/16.
//  Copyright © 2016 Silent H Designs. All rights reserved.
//

typealias EncodedObject = [String: AnyObject]

protocol Codeable: Decodeable, Encodeable {}

protocol Decodeable {
    init(decoder: DecoderType) throws
}

protocol Encodeable {
    func encode(encoder: EncoderType) throws
}



