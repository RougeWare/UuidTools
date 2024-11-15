//
//  UuidFormat.swift
//
//
//  Created by Ky on 2024-05-27.
//

import Foundation
import RegexBuilder



/// A way to format a UUID to/from a string
public enum UuidFormat: String, CaseIterable, Sendable, Hashable {
    
    /// The standard format: `2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8`
    case standard
    
    /// A Base64-encoded form of the raw bits of the UUID: `LT+2tgkNT72KwkKNxTb/6A==`
    case base64
    
    /// Just like `base64`, but without the trailing `==`: `LT+2tgkNT72KwkKNxTb/6A`
    case truncatedBase64
    
    
    /// The most likely common UUID format
    public static let `default` = standard
}



// MARK: - API

public extension UuidFormat {
    
    /// Takes in the given string and, assuming it's a well-formatted UUID, detects that format and initializes this instance as that format.
    ///
    /// ### Example
    /// ```swift
    /// let format1 = try UuidFormat(detectingFormatIn: "LT+2tgkNT72KwkKNxTb/6A")
    /// print(format) // truncatedBase64
    ///
    /// let format2 = try UuidFormat(detectingFormatIn: "I am not a UUID at all 😈")
    ///     // throws: I tried to figure out what format that was in, but it didn't seem to match any I expected. Check it to make sure it's right!
    /// ```
    ///
    /// - Parameter formattedUuid: The string which is a well-formatted UUID
    /// - Throws: a ``UuidFormat.Error`` if something goes horribly wrong (for example: you pass a non-UUID string. Scandalous!)
    init(detectingFormatIn formattedUuid: String) throws(Error) {
        guard let format = Self.allCases.first(where: { format in
            do {
                return nil != (try format.regex.wholeMatch(in: formattedUuid))
            }
            catch {
                print("ERROR: Tell Ky that their", format, "regex didn't work:", error)
                return false
            }
        })
        else {
            if let _ = UUID(uuidString: formattedUuid) {
                self = .standard
            }
            throw .couldNotDetectFormat
        }
        
        self = format
    }
    
    
    /// Applies this format to the given UUID.
    ///
    /// Since this uses a proper `UUID` structure, this always succeeds.
    ///
    /// - Parameter rawValue: The UUID to be formatted
    /// - Returns: The well-formatted string version of the given UUID
    func apply(to rawValue: UUID) -> String {
        switch self {
        case .standard:
            Self.format_standard(rawValue)
        case .base64:
            Self.format_base64(rawValue)
        case .truncatedBase64:
            Self.format_truncatedBase64(rawValue)
        }
    }
    
    
    /// Converts the given UUID string to one in this format, assuming the given string is in fact a well-formatted UUID string
    ///
    /// ### Example
    /// ```swift
    /// let converted1 = try UuidFormat.standard.convert("LT+2tgkNT72KwkKNxTb/6A")
    /// print(converted1) // 2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8
    ///
    /// let converted2 = try UuidFormat.standard.convert("I am not a UUID at all 😈")
    ///     // throws: I tried to figure out what format that was in, but it didn't seem to match any I expected. Check it to make sure it's right!
    /// ```
    ///
    /// - Parameter formattedUuid: The string which is a well-formatted UUID
    /// - Throws: a ``UuidFormat/Error`` if something goes horribly wrong (for example: you pass a non-UUID string. Scandalous!)
    ///
    ///
    /// - SeeAlso: ``UuidFormat/init(detectingFormatIn:)``
    func convert(_ formattedUuid: String) throws(Error) -> String {
        let detectedFormat: Self
        
        do {
            detectedFormat = try Self(detectingFormatIn: formattedUuid)
        }
        catch .couldNotDetectFormat {
            throw .malformed(expected: self)
        }
        
        guard self != detectedFormat else { return formattedUuid } // if it's already in this format, do nothing
        return try self.apply(to: detectedFormat.parse(formattedUuid))
    }
    
    
    /// Converts the given string to a UUID, assuming it's in this format.
    ///
    /// ### Example
    /// ```swift
    /// let parsed1 = try UuidFormat.truncatedBase64.parse("LT+2tgkNT72KwkKNxTb/6A")
    /// print(parsed1) // 2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8
    ///
    /// let parsed2 = try UuidFormat.standard.convert("LT+2tgkNT72KwkKNxTb/6A")
    ///     // throws: I expected a UUID formatted as standard (hex), but I got something different
    /// ```
    ///
    /// - Parameter formattedUuid: The string which is a well-formatted UUID in this format
    /// - Throws: a ``UuidFormat/Error`` if something goes horribly wrong (for example: you pass a string which doesn't match this format. Horrid!)
    @inlinable
    func parse(_ formattedUuid: String) throws(Error) -> UUID {
        switch self {
        case .standard:
            try Self.parse_standard(formattedUuid)
        case .base64:
            try Self.parse_base64(formattedUuid)
        case .truncatedBase64:
            try Self.parse_truncatedBase64(formattedUuid)
        }
    }
    
    
    /// Converts the given string to a UUID, assuming it's a well-formatted UUID string.
    ///
    /// The given UUID string must be in any format recognized by this package.
    ///
    /// ### Example
    /// ```swift
    /// let parsed1 = try UuidFormat.parse("LT+2tgkNT72KwkKNxTb/6A")
    /// print(parsed1) // 2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8
    ///
    /// let parsed2 = try UuidFormat.parse("I am not a UUID at all 😈")
    ///     // throws: I tried to figure out what format that was in, but it didn't seem to match any I expected. Check it to make sure it's right!
    /// ```
    ///
    /// - Parameter formattedUuid: The string which is a well-formatted UUID in any format
    static func parse(_ formattedUuid: String) throws(Error) -> UUID {
        try parse_any(formattedUuid)
    }
}



// MARK: UUID extension API

public extension UUID {
    
    /// Applies the given format to this UUID.
    ///
    /// This always succeeds.
    ///
    /// - Parameter formattedUuid: The string which is a well-formatted UUID in this format
    /// - Returns: The well-formatted string version of the given UUID
    func format(as format: UuidFormat) -> String {
        format.apply(to: self)
    }
    
    
    /// Converts the given string to a UUID, assuming it's in the given format.
    ///
    /// ### Example
    /// ```swift
    /// let parsed1 = try UUID("LT+2tgkNT72KwkKNxTb/6A")
    /// print(parsed1) // 2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8
    ///
    /// let parsed2 = try UUID("I am not a UUID at all 😈")
    ///     // throws: I expected a UUID formatted as standard (hex), but I got something different
    /// ```
    ///
    /// - Parameters:
    ///   - formattedUuid: The string which is a well-formatted UUID in this format
    ///   - format:        _optional_ - The format which you know the given string is in.
    ///                    While this format is optional, providing it can significantly improve performance.
    ///                    Omitting this format argument means that the format will be auto-detected by comparing the string against all known formats until one matches.
    ///                    That is to say, prividing this argument means this initializer is `O(1)` performance complexity, but omitting this argument changes that  to `O(n)` where `n` is the number of formats this package knows about.
    ///
    /// - Throws: a ``UuidFormat/Error`` if something goes horribly wrong (for example: you pass a string which doesn't match this format. Horrid!)
    init(_ formattedUuid: String) throws(UuidFormat.Error) {
        self = try UuidFormat.parse(formattedUuid)
    }
    
    
    /// Converts the given string to a UUID, assuming it's in the given format.
    ///
    /// ### Example
    /// ```swift
    /// let parsed1 = try UUID("LT+2tgkNT72KwkKNxTb/6A", format: .truncatedBase64)
    /// print(parsed1) // 2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8
    ///
    /// let parsed2 = try UUID("LT+2tgkNT72KwkKNxTb/6A", format: .standard)
    ///     // throws: I expected a UUID formatted as standard (hex), but I got something different
    /// ```
    ///
    /// - Parameters:
    ///   - formattedUuid: The string which is a well-formatted UUID in this format
    ///   - format:        _optional_ - The format which you know the given string is in.
    ///                    While this format is optional, providing it can significantly improve performance.
    ///                    Omitting this format argument means that the format will be auto-detected by comparing the string against all known formats until one matches.
    ///                    That is to say, prividing this argument means this initializer is `O(1)` performance complexity, but omitting this argument changes that  to `O(n)` where `n` is the number of formats this package knows about.
    ///
    /// - Throws: a ``UuidFormat/Error`` if something goes horribly wrong (for example: you pass a string which doesn't match this format. Horrid!)
    init(_ formattedUuid: String, format: UuidFormat) throws(UuidFormat.Error) {
        self = try format.parse(formattedUuid)
    }
}



// MARK: - Formatting guts

private extension UuidFormat {
    
    /// Applies the standard format to the given UUID
    ///
    /// Since this uses a proper `UUID` structure, this always succeeds.
    ///
    /// - Parameter rawValue: The UUID to be formatted
    /// - Returns: The standard-formatted string version of the given UUID
    static func format_standard(_ rawValue: UUID) -> String {
        rawValue.uuidString
    }
    
    
    /// Applies the base64 format to the given UUID
    ///
    /// Since this uses a proper `UUID` structure, this always succeeds.
    ///
    /// - Parameter rawValue: The UUID to be formatted
    /// - Returns: The base64-formatted string version of the given UUID
    static func format_base64(_ rawValue: UUID) -> String {
        rawValue.data.base64EncodedString()
    }
    
    
    /// Applies the truncated-base64 format to the given UUID
    ///
    /// Since this uses a proper `UUID` structure, this always succeeds.
    ///
    /// - Parameter rawValue: The UUID to be formatted
    /// - Returns: The truncated-base64-formatted string version of the given UUID
    static func format_truncatedBase64(_ rawValue: UUID) -> String {
        .init(format_base64(rawValue).prefix(22))
        // see Test_UuidFormat.guaranteeTruncatedBase64FormattingWorksAsExpected()
    }
}



extension Regex: @unchecked @retroactive Sendable {}
extension Dictionary: @unchecked Sendable where Key: Sendable, Value: Sendable {}



internal extension UuidFormat {
    
    /// A permanent cache of all format regexes
    private static let regexes = [UuidFormat : Regex<Substring>](uniqueKeysWithValues: allCases.map {
        ($0, $0.__generateRegex())
    })
    
    
    /// Immediately generates a regular expression which matches this format.
    ///
    /// This is `__`discouraged because it creates a new instance every time. Instead, use ``UuidFormat/regex``, which always returns a cached/pre-computed instance.
    ///
    /// - Returns: A newly-generated regular expression matching this format
    private func __generateRegex() -> Regex<Substring> {
        switch self {
        case .standard:
            // C614065F-0B45-4B9D-803E-013FF515E8FB
            /\b[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\b/.ignoresCase()
            
        case .base64:
            // xhQGXwtFS52APgE/9RXo+w==
            /\b[a-zA-Z0-9\+\/]{22}==\b/
            
        case .truncatedBase64:
            // xhQGXwtFS52APgE/9RXo+w
            // 7037AE0B90E1DCFFEDAE3C
            /\b[a-zA-Z0-9\+\/]{22}\b/
        }
    }
    
    
    /// A regex matching this format.
    ///
    /// - Complexity: O(1) • This looks up a cached/precomputed value every time
    var regex: Regex<Substring> {
        guard let regex = Self.regexes[self] else {
            print("⚠️ No regex for \(self)")
            assertionFailure("tbh this shouldn't be possible. I tried to get this format's regex out of the `regexes` dictionary, which is automatically prepopulated with all format regexes, but somehow the one for \(self) wasn't there.")
            return __generateRegex()
        }
        
        return regex
    }
    
    
    /// Parses the given well-formatted string into a UUID, assuming the given string uses a format known to this package
    ///
    /// ### Example
    /// ```swift
    /// let parsed1 = try UuidFormat.parse("LT+2tgkNT72KwkKNxTb/6A")
    /// print(parsed1) // 2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8
    ///
    /// let parsed2 = try UuidFormat.parse("I am not a UUID at all 😈")
    ///     // throws: I tried to figure out what format that was in, but it didn't seem to match any I expected. Check it to make sure it's right!
    /// ```
    ///
    /// - Parameter formattedUuid: Any well-formatted string representation of a UUID
    /// - Throws: an ``UuidFormat/Error`` if this couldn't detect the format in the given string
    @inlinable
    static func parse_any(_ formattedUuid: String) throws(Error) -> UUID {
        try UuidFormat(detectingFormatIn: formattedUuid)
            .parse(formattedUuid)
    }
    
    
    /// Parses the given string as the standard format
    ///
    /// The standard format is 5 groups of hyphen-separated hex digits, and looks like this: `2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8`
    ///
    /// - Parameter formattedUuid: Any standard-formatted string representation of a UUID
    /// - Throws: an ``UuidFormat/Error`` if the given string wasn't in the standard UUID format
    @inlinable
    static func parse_standard(_ formattedUuid: String) throws(Error) -> UUID {
        guard let parsed = UUID(uuidString: formattedUuid) else {
            throw .malformed(expected: .standard)
        }
        
        return parsed
    }
    
    
    /// A Base64-encoded form of the raw bits of the UUID: `LT+2tgkNT72KwkKNxTb/6A==`
    @inlinable
    static func parse_base64(_ formattedUuid: String) throws(Error) -> UUID {
        guard let data = Data(base64Encoded: formattedUuid),
              let parsed = UUID(data: data)
        else {
            throw .malformed(expected: .base64)
        }
        
        return parsed
    }
    
    
    /// Just like `base64`, but without the trailing `==`: `LT+2tgkNT72KwkKNxTb/6A`
    @inlinable
    static func parse_truncatedBase64(_ formattedUuid: String) throws(Error) -> UUID {
        guard let data = Data(base64Encoded: formattedUuid + "=="),
              let parsed = UUID(data: data)
        else {
            throw .malformed(expected: .truncatedBase64)
        }
        
        return parsed
    }
}



// MARK: - Error handling

public extension UuidFormat {
    
    /// An error which can occur when dealing with UUID formats
    enum Error: Swift.Error, LocalizedError, Equatable {
        
        /// Thrown when asked to convert from a spcific format, but the input wasn't in that format.
        ///
        /// ### Example
        /// ```swift
        /// let uuid = try UuidFormat.standard.parse("LT+2tgkNT72KwkKNxTb/6A")
        ///     // throws: I expected a UUID formatted as standard (hex), but I got something different
        /// ```
        case malformed(expected: UuidFormat)
        
        /// Thown when asked to detect the format of some stringified UUID, but it wasn't in any format known to this package
        ///
        /// ### Example
        /// ```swift
        /// let uuid = try UuidFormat(detectingFormatIn: "I am not a UUID at all 😈")
        ///     // throws: I tried to figure out what format that was in, but it didn't seem to match any I expected. Check it to make sure it's right!
        /// ```
        case couldNotDetectFormat
        
        
        public var errorDescription: String? {
            switch self {
            case .malformed(let expected):
                "I expected a UUID formatted as \(expected.description), but I got something different"
                
            case .couldNotDetectFormat:
                "I tried to figure out what format that was in, but it didn't seem to match any I expected. Check it to make sure it's right!"
            }
        }
    }
}



// MARK: - Stringification

extension UuidFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .standard:
            "standard (hex)"
        case .base64:
            "base64"
        case .truncatedBase64:
            "truncated base64"
        }
    }
}
