//
//  MediaGridItemView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import NukeUI
import SwiftUI

struct MediaGridItemView: View {
    let title: String
    let subtitle: String?
    let imageURL: URL?
    let aspectRatio: CGFloat
    let circle: Bool
    
    let onTap: () -> Void

    var body: some View {
        
        Button {
            onTap()
        } label: {
            VStack(alignment: circle ? .center : .leading) {
                LazyImage(url: imageURL) { state in
                    if let image = state.image {
                        image
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .redacted(reason: .placeholder)
                    }
                }
                .aspectRatio(aspectRatio, contentMode: .fill)
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
        .buttonStyle(BounceButtonStyle())
    }
}

// MARK: - Mocks
extension MediaGridItemView {

    static let mock: Self = MediaGridItemView(
        title: "Title",
        subtitle: "Subtitle",
        imageURL: nil,
        aspectRatio: 0.7,
        circle: false,
        onTap: {}
    )

    static let mockRounded: Self = MediaGridItemView(
        title: "Artist Title",
        subtitle: nil,
        imageURL: nil,
        aspectRatio: 1,
        circle: true,
        onTap: {}
    )
}

// MARK: - Preview
struct MediaGridItemView_Previews: PreviewProvider {
    static var previews: some View {
        MediaGridItemView.mock
            .frame(width: 100, height: 70)
    }
}
