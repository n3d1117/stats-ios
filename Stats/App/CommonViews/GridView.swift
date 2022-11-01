//
//  GridView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI

struct GridView<Content: View>: View {

    @ViewBuilder let content: () -> Content

    private var width: CGFloat { 80 }
    private var spacing: CGFloat { 20 }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: width), spacing: spacing, alignment: .top)], spacing: spacing) {
            content()
        }
    }
}
