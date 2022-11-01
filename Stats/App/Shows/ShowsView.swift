//
//  ShowsView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import Models
import DependencyInjection
import Networking

struct ShowsView: View {

    @EnvironmentObject var dataLoader: NetworkDataLoader
    
    @Environment(\.listLayout) var listLayout

    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    showsView(for: response.tvShows)
                        .padding()
                }.refreshable {
                    await dataLoader.load()
                }

            case .loading:
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Dummy header")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        if listLayout {
                            MoviesListViewMock()
                        } else {
                            MoviesGridViewMock()
                        }
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

    private func showsView(for shows: [TVShow]) -> some View {

        let recentlyWatched: [TVShow] = shows
            .filter { !$0.isFavorite }
            .sorted(by: { $0.lastWatched > $1.lastWatched })

        let favorites = shows.filter { $0.isFavorite }

        return VStack(spacing: 30) {

            if !recentlyWatched.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recently watched")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    ShowsGridView(shows: recentlyWatched)
                }
            }

            if !favorites.isEmpty {
                VStack(alignment: .leading) {
                    Text("Favorites")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    ShowsGridView(shows: favorites)
                }
            }
        }.animation(.default, value: listLayout)
    }
}

struct ShowsGridView: View {

    let shows: [TVShow]
    
    @Environment(\.listLayout) var listLayout

    var body: some View {
        ZStack {
            if !listLayout {
                GridView {
                    ForEach(shows) { show in
                        MediaGridItemView(
                            title: show.title,
                            subtitle: String(show.episode),
                            imageURL: URL(string: (API.baseImageUrl + show.img).urlEncoded),
                            aspectRatio: 0.7,
                            circle: false
                        )
                    }
                }
            } else {
                LazyVStack {
                    ForEach(shows) { show in
                        MediaListItemView(
                            title: show.title,
                            subtitle: String(show.episode),
                            imageURL: URL(string: (API.baseImageUrl + show.img).urlEncoded),
                            aspectRatio: 0.7,
                            circle: false
                        )
                    }
                }
            }
        }
    }
}

struct ShowsView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            ShowsView()
                .task {
                    DependencyValues[\.networkService] = .mock(shows: [.boris])
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
        }
    }

    static var previews: some View {
        Preview()
    }
}
