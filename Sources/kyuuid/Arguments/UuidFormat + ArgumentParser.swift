//
//  UuidFormat + ArgumentParser.swift
//  kyuuid
//
//  Created by Ky on 2024-10-24.
//

import Foundation

import ArgumentParser
import UuidTools



extension UuidFormat: ExpressibleByArgument {
    
//    public static let allValueStrings = allCases.map {
//        $0.rawValue
//    }
    
    
    var discussion: String {
        switch self {
        case .standard:
            "the typical 5-segment hex-digit UUID string"
            
        case .base64:
            "a Base64-encoded form of the raw bits of the UUID"
            
        case .truncatedBase64:
            "just like `\(Self.base64.rawValue)`, but without the trailing `==`"
        }
    }
}
