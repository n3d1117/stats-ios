//
//  BounceButtonStyle.swift
//  Stats
//
//  Created by ned on 02/12/22.
//

import SwiftUI

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.85, blendDuration: 0.2),
                value: configuration.isPressed
            )
    }
}
