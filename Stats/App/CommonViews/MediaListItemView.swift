//
//  MediaListItemView.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import NukeUI
import SwiftUI

struct MediaListItemView: View {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    let aspectRatio: CGFloat
    let circle: Bool

    var body: some View {
        HStack {
            LazyImage(url: imageURL) { state in
                if let image = state.image {
                    image
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .redacted(reason: .placeholder)
                }
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
            .frame(height: 60)
            .if(circle, transform: { $0.clipShape(Circle()) })
            .if(!circle, transform: { $0.clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous)) })

            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 15))
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .lineLimit(1)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Mocks
extension MediaListItemView {

    static let mock: Self = MediaListItemView(
        title: "This is a movie title",
        subtitle: "Subtitle",
        imageURL: nil,
        aspectRatio: 0.7,
        circle: false
    )

    static let mockRounded: Self = MediaListItemView(
        title: "This is an artist title",
        subtitle: nil,
        imageURL: nil,
        aspectRatio: 1,
        circle: true
    )
}

// MARK: - Preview
struct MediaListItemView_Previews: PreviewProvider {
    static var previews: some View {
        MediaListItemView.mock
    }
}
