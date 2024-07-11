// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct kyuuid: ParsableCommand {
    
    @Option
    var format: Format = .truncatedBase64
    
    mutating func run() throws {
        let uuid = UUID()
    }
}
