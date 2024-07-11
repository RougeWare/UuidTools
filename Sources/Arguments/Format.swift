//
//  Format.swift
//
//
//  Created by Ky on 2024-05-27.
//

import Foundation

import ArgumentParser



enum Format: String, ExpressibleByArgument {
    case standard
    case base64
    case truncatedBase64
}
