//
//  MediaContentView.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import Models
import Networking
import SwiftUI

struct MediaContentView: View {

    let media: [any Media]

    @Environment(\.layoutType) var layoutType

    var body: some View {
        ZStack {
            switch layoutType {
            case .grid:
                GridView {
                    ForEach(media, id: \.id) { item in
                        MediaGridItemView(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageURL: URL(string: (API.baseImageUrl + item.image).urlEncoded),
                            aspectRatio: item.aspectRatio,
                            circle: item.circle
                        )
                    }
                }
            case .list:
                LazyVStack {
                    ForEach(media, id: \.id) { item in
                        MediaListItemView(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageURL: URL(string: (API.baseImageUrl + item.image).urlEncoded),
                            aspectRatio: item.aspectRatio,
                            circle: item.circle
                        )
                    }
                }
            }
        }
    }
}
