//
//  Test_UuidFormat.swift
//  kyuuid
//
//  Created by Ky on 2024-10-28.
//

import Foundation
import Testing

import UuidTools



struct Test_UuidFormat {
    
    @Test
    func guaranteeAllFormatsAreCovered() async throws {
        UuidFormat.allCases.forEach { format in
            switch format {
            case .base64:          print("I've written all appropriate tests for the Base64 format – Ky")
            case .truncatedBase64: print("I've written all appropriate tests for the Truncated Base64 format – Ky")
            case .standard:        print("I've written all appropriate tests for the Standard format – Ky")
                
            @unknown default:
                try! #require(Bool(false), "You much write tests to cover the \(format) format")
                fatalError()
            }
        }
    }
    
    
    
    // MARK: - UuidFormat.init(detectingFormatIn:String)
    
    @Test("UuidFormat.init(detectingFormatIn:String)")
    func init_detectingFormatIn_String() async throws {
        #expect(try .truncatedBase64 == UuidFormat(detectingFormatIn: "LT+2tgkNT72KwkKNxTb/6A"))
        #expect(try .base64 == UuidFormat(detectingFormatIn: "LT+2tgkNT72KwkKNxTb/6A=="))
        #expect(try .standard == UuidFormat(detectingFormatIn: "2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8"))
        
        #expect(try .standard == UuidFormat(detectingFormatIn: "00000000-0000-0000-0000-000000000000"))
        #expect(try .standard == UuidFormat(detectingFormatIn: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"))
        
        #expect(throws: UuidFormat.Error.couldNotDetectFormat) {
            try UuidFormat(detectingFormatIn: "I'm not a UUID at all 😈")
        }
        
        #expect(throws: UuidFormat.Error.couldNotDetectFormat) {
            try UuidFormat(detectingFormatIn: "")
        }
        
        #expect(throws: UuidFormat.Error.couldNotDetectFormat) {
            try UuidFormat(detectingFormatIn: "2D3FB6B6090D4FBD8AC2428DC536FFE8")
        }
    }
    
    
    // MARK: - Apply format to UUID
    
    @Test("Apply format to UUID", arguments: UuidFormat.allCases)
    func apply_to_UUID(_ targetFormat: UuidFormat) async {
        for precomputed in UuidFormat.precomputedFormats {
            #expect(precomputed[targetFormat] == targetFormat.apply(to: precomputed.uuid))
            #expect(precomputed[targetFormat] == precomputed.uuid.format(as: targetFormat))
        }
    }
    
    
    
    // MARK: - Convert string to string using explicit format
    
    @Test("Convert string to string using explicit format", arguments: UuidFormat.allCases)
    func convertStringToStringUsingExplicitFormat(_ targetFormat: UuidFormat) async throws {
        for precomputed in UuidFormat.precomputedFormats {
            for inputFormat in UuidFormat.allCases {
                #expect(try targetFormat.convert(precomputed[inputFormat]) == precomputed[targetFormat])
            }
        }
        
        for undetectableFormat in UuidFormat.exampleUndetectableFormats {
            #expect(throws: UuidFormat.Error.malformed(expected: targetFormat)) {
                try targetFormat.convert(undetectableFormat)
            }
        }
    }
    
    
    
    // MARK: - Convert string to UUID using explicit format
    
    @Test("Convert string to UUID using explicit format", arguments: UuidFormat.allCases)
    func convertStringToUuidUsingExplicitFormat(_ targetFormat: UuidFormat) async throws {
        for precomputed in UuidFormat.precomputedFormats {
            #expect(try UUID(precomputed[targetFormat], format: targetFormat) == precomputed.uuid)
        }
        
        for undetectableFormat in UuidFormat.exampleUndetectableFormats {
            #expect(throws: UuidFormat.Error.malformed(expected: targetFormat)) {
                try UUID(undetectableFormat, format: targetFormat)
            }
        }
    }
    
    
    
    // MARK: - Convert string to UUID by guessing format
    
    @Test("Convert string to UUID by guessing format", arguments: UuidFormat.allCases)
    func convertStringToUuidByGuessingFormat(_ targetFormat: UuidFormat) async throws {
        for precomputed in UuidFormat.precomputedFormats {
            #expect(try UuidFormat.parse(precomputed[targetFormat]) == precomputed.uuid)
            #expect(try UUID(precomputed[targetFormat]) == precomputed.uuid)
        }
        
        for undetectableFormat in UuidFormat.exampleUndetectableFormats {
            #expect(throws: UuidFormat.Error.couldNotDetectFormat) {
                try UUID(undetectableFormat)
            }
            
            #expect(throws: UuidFormat.Error.couldNotDetectFormat) {
                try UuidFormat.parse(undetectableFormat)
            }
        }
    }
    
    
    
    // MARK: - general
    
    @Test
    func guaranteeTruncatedBase64FormattingWorksAsExpected() async throws {
        // Fuzz 1000 UUIDs
        for _ in 1...1000 {
            let uuid = UUID()
            let formatted_base64 = uuid.format(as: .base64)
            let formatted_truncatedBase64 = uuid.format(as: .truncatedBase64)
            let prefixed_truncatedBase64 = String(formatted_base64.prefix(while: { $0 != "=" }))
            
            #expect(formatted_truncatedBase64 == prefixed_truncatedBase64)
        }
    }
}
