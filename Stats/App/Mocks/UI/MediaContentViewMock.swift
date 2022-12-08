//
//  MediaContentViewMock.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import SwiftUI

struct MediaGridViewMock: View {
    var body: some View {
        GridView {
            ForEach(0 ..< 30, id: \.self) { _ in
                MediaGridItemView.mock
            }
        }
    }
}

struct MediaListViewMock: View {
    var body: some View {
        VStack {
            ForEach(0 ..< 30, id: \.self) { _ in
                MediaListItemView.mock
            }
        }
    }
}

struct MediaGridCircleViewMock: View {
    var body: some View {
        GridView {
            ForEach(0 ..< 30, id: \.self) { _ in
                MediaGridItemView.mockRounded
            }
        }
    }
}

struct MediaListCircleViewMock: View {
    var body: some View {
        VStack {
            ForEach(0 ..< 30, id: \.self) { _ in
                MediaListItemView.mockRounded
            }
        }
    }
}
