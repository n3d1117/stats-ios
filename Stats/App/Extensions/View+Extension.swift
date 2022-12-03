//
//  View+Extension.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

// MARK: - Conditional modifier
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - View size reader
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            self
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometryProxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                    }
                )
                .hidden()
                .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
        )
    }
}
