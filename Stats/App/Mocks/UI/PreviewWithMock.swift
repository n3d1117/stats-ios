//
//  PreviewWithMock.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

@available(iOS 13.0, *)
public struct PreviewWithMock<T>: View where T: View {
    let viewToPreview: T

    public init(_ viewToPreview: T, initMocks: () -> Void) {
        self.viewToPreview = viewToPreview
        initMocks()
    }

    public var body: some View {
        viewToPreview
    }
}
