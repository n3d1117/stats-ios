//
//  Error.swift
//  
//
//  Created by ned on 31/10/22.
//

import Foundation

public enum StatsError: String {
    case unknown = "Unknown error"
}

extension StatsError: LocalizedError {
    public var errorDescription: String? { rawValue }
}
