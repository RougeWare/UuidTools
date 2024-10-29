//
//  UUID + conveniences.swift
//
//  Adapted from https://gist.github.com/xsleonard/b28573142215e25858bebb9ba907829c#file-uuid-extensions-swift
//

import Foundation



public extension UUID {
    
    /// Takes all 128 bits of this UUID and represents them using two 64-bit unsigned integers.
    ///
    /// This is Big-Endian, meaning the UUID is represented in the same order here as it is in the Swift representation and in the standard string format.
    ///
    /// That is to say, the UUID with this value:
    /// - `   2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8`
    /// is represented like this:
    /// - `(0x2D3FB6B6090D4FBD, 0x8AC2428DC536FFE8)`
    var integers: (UInt64, UInt64) {
        // UUID is 128-bit, we need two 64-bit values to represent it
        (
              UInt64(self.uuid.0 )
            | UInt64(self.uuid.1 ) <<  8
            | UInt64(self.uuid.2 ) << (8 * 2)
            | UInt64(self.uuid.3 ) << (8 * 3)
            | UInt64(self.uuid.4 ) << (8 * 4)
            | UInt64(self.uuid.5 ) << (8 * 5)
            | UInt64(self.uuid.6 ) << (8 * 6)
            | UInt64(self.uuid.7 ) << (8 * 7)
              ,
              UInt64(self.uuid.8 )
            | UInt64(self.uuid.9 ) <<  8
            | UInt64(self.uuid.10) << (8 * 2)
            | UInt64(self.uuid.11) << (8 * 3)
            | UInt64(self.uuid.12) << (8 * 4)
            | UInt64(self.uuid.13) << (8 * 5)
            | UInt64(self.uuid.14) << (8 * 6)
            | UInt64(self.uuid.15) << (8 * 7)
        )
    }
    
    
    /// Uses the 128 bits of the given two 64-bit unsigned integers, and places them as the bits of a UUID.
    ///
    /// This uses Big-Endian, meaning the UUID is represented in the same order here as it is in the Swift representation and in the standard string format.
    ///
    /// That is to say, the UUID with this value:
    /// - `   2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8`
    /// is returned like this:
    /// - `(0x2D3FB6B6090D4FBD, 0x8AC2428DC536FFE8)`
    init(_ integers: (UInt64, UInt64)) {
        let a = integers.0
        let b = integers.1
        
        self.init(uuid: (
            UInt8( a             & 0xFF),
            UInt8((a >>  8     ) & 0xFF),
            UInt8((a >> (8 * 2)) & 0xFF),
            UInt8((a >> (8 * 3)) & 0xFF),
            UInt8((a >> (8 * 4)) & 0xFF),
            UInt8((a >> (8 * 5)) & 0xFF),
            UInt8((a >> (8 * 6)) & 0xFF),
            UInt8((a >> (8 * 7)) & 0xFF),
            
            UInt8( b             & 0xFF),
            UInt8((b >>  8     ) & 0xFF),
            UInt8((b >> (8 * 2)) & 0xFF),
            UInt8((b >> (8 * 3)) & 0xFF),
            UInt8((b >> (8 * 4)) & 0xFF),
            UInt8((b >> (8 * 5)) & 0xFF),
            UInt8((b >> (8 * 6)) & 0xFF),
            UInt8((b >> (8 * 7)) & 0xFF)
        ))
    }
    
    
    /// Converts this UUID to `Data`, maintaining bit order.
    ///
    /// This uses Big-Endian, meaning the UUID is represented in the same order here as it is in the Swift representation and in the standard string format.
    ///
    /// That is to say, the UUID with this value:
    /// - `2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8`
    /// is returned like this:
    /// - `[0x2D, 0x3F, 0xB6, 0xB6, 0x09, 0x0D, 0x4F, 0xBD, 0x8A, 0xC2, 0x42, 0x8D, 0xC5, 0x36, 0xFF, 0xE8]`
    var data: Data {
        var data = Data(count: 16)
        // uuid is a tuple type which doesn't have dynamic subscript access...
        data[ 0] = self.uuid.0
        data[ 1] = self.uuid.1
        data[ 2] = self.uuid.2
        data[ 3] = self.uuid.3
        data[ 4] = self.uuid.4
        data[ 5] = self.uuid.5
        data[ 6] = self.uuid.6
        data[ 7] = self.uuid.7
        data[ 8] = self.uuid.8
        data[ 9] = self.uuid.9
        data[10] = self.uuid.10
        data[11] = self.uuid.11
        data[12] = self.uuid.12
        data[13] = self.uuid.13
        data[14] = self.uuid.14
        data[15] = self.uuid.15
        return data
    }
    
    
    /// Initialize a UUID from raw data.
    ///
    /// The given data **MUST** be precisely as long as a UUID, no more no less.
    /// - That is the same size as the value returned from ``UUID/data``.
    /// - That is the same size as `MemoryLayout<uuid_t>.size`.
    /// - That is 128 bits, 16 bytes.
    ///
    /// If the given data is not the proper size, this will return `nil`.
    ///
    /// - SeeAlso: ``NSUUID/init(uuidBytes:)``
    ///
    /// - Parameter data: 128 bits of pure, raw, unprocessed UUID data
    init?(data: Data) {
        guard data.count == MemoryLayout<uuid_t>.size else {
            return nil
        }
        
        let value: UUID? = data.withUnsafeBytes {
            guard let baseAddress = $0.bindMemory(to: UInt8.self).baseAddress else {
                return nil
            }
            return NSUUID(uuidBytes: baseAddress) as UUID
        }
        
        guard let value else { return nil }
        self = value
    }
}
