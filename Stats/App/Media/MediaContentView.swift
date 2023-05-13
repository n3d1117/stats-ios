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
    let media: [AnyMediaModel]
    let onTap: (Media) -> Void

    @Environment(\.layoutType) var layoutType

    var body: some View {
        ZStack {
            switch layoutType {
            case .grid:
                GridView {
                    ForEach(media) { item in
                        MediaGridItemView(
                            title: item.base.title,
                            subtitle: item.base.subtitle,
                            imageURL: item.base.imageURL,
                            aspectRatio: item.base.aspectRatio,
                            circle: item.base.circle
                        ) {
                            onTap(item.base)
                        }
                    }
                }
            case .list:
                LazyVStack {
                    ForEach(media) { item in
                        MediaListItemView(
                            title: item.base.title,
                            subtitle: item.base.subtitle,
                            imageURL: item.base.imageURL,
                            aspectRatio: item.base.aspectRatio,
                            circle: item.base.circle
                        ) {
                            onTap(item.base)
                        }
                    }
                }
            }
        }
    }
}
