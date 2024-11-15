//
//  Test_UUID_conveniences.swift
//  kyuuid
//
//  Created by Ky on 2024-10-29.
//

import Testing

import UuidTools



struct Test_UUID_conveniences {

    @Test("uuid.integers")
    func integers() async throws {
        #expect(UUID.testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8.integers
                       == (0x2D3FB6B6090D4FBD, 0x8AC2428DC536FFE8))
    }
    
    @Test("UUID.init(_:(UInt64,UInt64))")
    func initWithintegers() async throws {
        #expect(UUID.testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8
                  == UUID((0x2D3FB6B6090D4FBD, 0x8AC2428DC536FFE8)))
    }
    
    @Test("uuid.data")
    func data() async throws {
        #expect(UUID.testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8.data
                  == Data([0x2D,0x3F,0xB6,0xB6, 0x09,0x0D, 0x4F,0xBD, 0x8A,0xC2, 0x42,0x8D,0xC5,0x36,0xFF,0xE8]))
    }
    
    @Test("UUID.init(data:Data)")
    func initWithData() async throws {
        #expect(UUID.testId__2D3FB6B6_090D_4FBD_8AC2_428DC536FFE8
                == UUID(data: Data([0x2D,0x3F,0xB6,0xB6, 0x09,0x0D, 0x4F,0xBD, 0x8A,0xC2, 0x42,0x8D,0xC5,0x36,0xFF,0xE8])))
    }
}
