// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

import UuidTools



@main
struct kyuuid: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for generating & formatting UUIDs.",
        
        discussion: """
        This utility only generates the version of UUIDs that Swift's Foundation library generates. When this utility was originally written (2024-05-30), that's UUIDv4.
        
        \(formatsDiscussion)
        """,

        // Commands can define a version for automatic '--version' support.
        version: "0.1.3-lambda.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [convert.self])
    
    
    @Option(help: "The output format of the UUID(s) this generates. See FORMATS for more info.", completion: .list(UuidFormat.allValueStrings))
    var format: UuidFormat = .default
    
    @Option(help: "The number of UUIDs to generate at once. Each UUID will be printed on its own line and formatted as specified with the `--format` option.")
    var `repeat`: UInt = 1
    
    mutating func run() throws {
        for _ in 1 ... max(1, self.repeat) {
            print(format.apply(to: UUID()))
        }
    }
}



private var formatsDiscussion: String {
    """
    FORMATS:
    
    This utility offers \(UuidFormat.allCases.count) different formatting options:
    
    \(UuidFormat.allCases.map { format in
    """
        \(format.rawValue):  \(format.discussion)
            Example: \(format.apply(to: .example))
    
    
    """}.joined())
    """
}
