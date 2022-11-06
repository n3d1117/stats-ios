//
//  GridView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

struct GridView<Content: View>: View {

    @ViewBuilder let content: () -> Content

    private let width: CGFloat
    private let spacing: CGFloat
    
    init(width: CGFloat = 80, spacing: CGFloat = 20, content: @escaping () -> Content) {
        self.width = width
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: width), spacing: spacing, alignment: .top)], spacing: spacing) {
            content()
        }
    }
}
