//
//  MusicView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import Models
import DependencyInjection
import Networking

struct MusicView: View {

    @EnvironmentObject var dataLoader: NetworkDataLoader

    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    artistsView(for: response.artists)
                        .padding()
                }

            case .loading:
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Dummy header")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        ArtistsGridViewMock()
                    }
                    .padding()
                    .redacted(reason: .placeholder)
                }

            case .failed(let error):
                GenericErrorView(error: error.localizedDescription) {
                    await dataLoader.load()
                }
            }
        }
        .animation(.default, value: dataLoader.state)
    }

    private func artistsView(for artists: [Artist]) -> some View {
        VStack(alignment: .leading) {
            Text("Music I'm listening to")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            ArtistsGridView(artists: artists)
        }
    }
}

struct ArtistsGridView: View {

    let artists: [Artist]

    var body: some View {
        GridView {
            ForEach(artists) { artist in
                MediaGridItemView(
                    title: artist.name,
                    subtitle: nil,
                    imageURL: URL(string: (API.baseImageUrl + artist.img).urlEncoded),
                    aspectRatio: 1,
                    circle: true
                )
            }
        }
    }
}

struct ArtistsGridView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            MusicView()
                .task {
                    DependencyValues[\.networkService] = .mock(artists: [.radiohead, .kanye], wait: true)
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
        }
    }

    static var previews: some View {
        Preview()
    }
}

struct ArtistsGridViewMock: View {
    var body: some View {
        GridView {
            ForEach(0..<30, id: \.self) { _ in
                MediaGridItemView.mockRounded
            }
        }
    }
}
