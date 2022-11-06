//
//  ChartGridItemView.swift
//  Stats
//
//  Created by ned on 04/11/22.
//

import SwiftUI
import NukeUI

struct ChartGridItemView: View {
    let title: String
    let subtitle: String?
    let imageURL: URL?

    var body: some View {
        VStack(alignment: .leading) {
            LazyImage(url: imageURL) { state in
                if let image = state.image {
                    image
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .redacted(reason: .placeholder)
                }
            }
            .aspectRatio(0.7, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

            Text(title)
                .font(.system(size: 14))
                .lineLimit(1)

            Text(subtitle ?? "")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .offset(y: 2)
        }
    }
}
