//
//  MediaGridItemView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import NukeUI

struct MediaGridItemView: View {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    let aspectRatio: CGFloat
    let circle: Bool

    var body: some View {
        VStack(alignment: circle ? .center : .leading) {
            LazyImage(url: imageURL) { state in
                if let image = state.image {
                    image
                        .aspectRatio(aspectRatio, contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .aspectRatio(aspectRatio, contentMode: .fill)
                        .redacted(reason: .placeholder)
                }
            }
            .if(circle, transform: { $0.clipShape(Circle()) })
            .if(!circle, transform: { $0.clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous)) })

            Text(title)
                .font(.system(size: 14))
                .lineLimit(1)

            if let subtitle {
                Text(subtitle)
                    .lineLimit(1)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .offset(y: 2)
            }
        }
    }
}

// MARK: - Mocks
extension MediaGridItemView {

    static let mock: Self = MediaGridItemView(
        title: "Title",
        subtitle: "Subtitle",
        imageURL: nil,
        aspectRatio: 0.7,
        circle: false
    )

    static let mockRounded: Self = MediaGridItemView(
        title: "Artist Title",
        subtitle: nil,
        imageURL: nil,
        aspectRatio: 1,
        circle: true
    )
}

// MARK: - Preview
struct MediaGridItemView_Previews: PreviewProvider {
    static var previews: some View {
        MediaGridItemView.mock
            .frame(width: 100, height: 70)
    }
}
