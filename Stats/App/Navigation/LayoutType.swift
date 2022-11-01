//
//  LayoutType.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import SwiftUI

enum LayoutType: String {
    case grid
    case list

    static let storageKey: String = "layoutType"
}

// MARK: - Environment value
private struct LayoutSwitchKey: EnvironmentKey {
    static let defaultValue: LayoutType = .grid
}

extension EnvironmentValues {
    var layoutType: LayoutType {
        get { self[LayoutSwitchKey.self] }
        set { self[LayoutSwitchKey.self] = newValue }
    }
}
