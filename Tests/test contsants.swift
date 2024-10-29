//
//  test contsants.swift
//  kyuuid
//
//  Created by Ky on 2024-10-28.
//

import Foundation

import UuidTools



extension UUID {
    
    static let testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8 = UUID(uuid: (0x2D,0x3F,0xB6,0xB6, 0x09,0x0D, 0x4F,0xBD, 0x8A,0xC2, 0x42,0x8D,0xC5,0x36,0xFF,0xE8))
    static let testId__null = UUID(uuid: (0,0,0,0,0, 0,0, 0,0, 0,0, 0,0,0,0,0))
    
    
    static let testIds = [
        testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8,
        .testId__null,
    ]
}



extension Array where Element == UUID {
    static var test: Self {
        .init(Element.testIds)
    }
}



extension UuidFormat {
    static let precomputedFormats: [Precomputed] = [
        .init(uuid: .testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8) { format in switch format {
            case .standard:        "2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8"
            case .base64:          "LT+2tgkNT72KwkKNxTb/6A=="
            case .truncatedBase64: "LT+2tgkNT72KwkKNxTb/6A"
        }},
        .init(uuid: .testId__null) { format in switch format {
            case .standard:        "00000000-0000-0000-0000-000000000000"
            case .base64:          "AAAAAAAAAAAAAAAAAAAAAA=="
            case .truncatedBase64: "AAAAAAAAAAAAAAAAAAAAAA"
        }},
    ]
    
    
    struct Precomputed {
        let uuid: UUID
        private let formats: [UuidFormat : String]
        
        init(uuid: UUID, formats: (UuidFormat) -> String) {
            self.uuid = uuid
            self.formats = Dictionary.init(uniqueKeysWithValues: UuidFormat.allCases.map { ($0, formats($0)) })
        }
        
        var standard: String { self[.standard] }
        var base64: String { self[.base64] }
        var truncatedBase64: String { self[.truncatedBase64] }
        
        
        subscript(_ format: UuidFormat) -> String {
            formats[format]!
        }
    }
}



extension UuidFormat {
    static let exampleUndetectableFormats: [String] = [
        "I'm not a UUID at all 😈",
        "",
        "2D3FB6B6090D4FBD8AC2428DC536FFE8",
    ]
}
