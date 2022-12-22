//
//  SettingsViewModel.swift
//  Stats
//
//  Created by ned on 22/12/22.
//

import Foundation

@MainActor final class SettingsViewModel: ObservableObject {
    
    @Published private(set) var appVersion: String? = nil
    
    init() {
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

extension Comparable {
    func clamped(_ f: Self, _ t: Self)  ->  Self {
        var r = self
        if r < f { r = f }
        if r > t { r = t }
        return r
    }
}
