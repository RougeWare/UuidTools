//
//  convert.swift
//
//
//  Created by Ky on 2024-05-27.
//

import Foundation

import ArgumentParser
import UuidTools



struct convert: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for converting UUIDs between formats.",
        
        discussion: """
        See the documentation for \(kyuuid._commandName) to learn more about the formats
        """,

        // Commands can define a version for automatic '--version' support.
        version: "0.1.1-lambda.4")
    
    @Option
    var to: UuidFormat = .default
    
    @Argument
    var uuid: String
    
    
    mutating func run() throws {
        print(try to.convert(uuid))
    }
}
