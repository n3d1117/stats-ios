//
//  LayoutType.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import SwiftUI

enum MediaLayoutType: String {
    case grid
    case list

    static let storageKey: String = "layoutType"
}

// MARK: - Environment value

private struct LayoutSwitchKey: EnvironmentKey {
    static let defaultValue: MediaLayoutType = .grid
}

extension EnvironmentValues {
    var layoutType: MediaLayoutType {
        get { self[LayoutSwitchKey.self] }
        set { self[LayoutSwitchKey.self] = newValue }
    }
}
