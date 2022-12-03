//
//  MediaView.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import DependencyInjection
import Models
import SwiftUI

struct MediaView: View {

    let mediaType: Route

    @EnvironmentObject var dataLoader: NetworkDataLoader
    @Environment(\.layoutType) var layoutType
    
    @State private var selection: Media? = nil
    @State private var showDetails: Bool = false
    @State private var sheetContentHeight: CGFloat = 190

    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    VStack(spacing: 30) {
                        switch mediaType {
                        case .movies: moviesView(response.movies)
                        case .tvShows: showsView(response.tvShows)
                        case .books: booksView(response.books)
                        case .music: artistsView(response.artists)
                        case .games: gamesView(response.games)
                        }
                    }
                    .padding()
                    .animation(.default, value: layoutType)

                }.refreshable {
                    await dataLoader.load()
                }

            case .loading:
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Dummy header")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))

                        switch (layoutType, mediaType) {
                        case (.list, .music): MediaListCircleViewMock()
                        case (.list, _): MediaListViewMock()
                        case (.grid, .music): MediaGridCircleViewMock()
                        case (.grid, _): MediaGridViewMock()
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

    @ViewBuilder
    private func moviesView(_ movies: [Movie]) -> some View {

        let recentlyWatched: [Movie] = movies
            .filter { !$0.isFavorite }
            .sorted(by: { $0.lastWatched > $1.lastWatched })

        let favorites: [Movie] = movies
            .filter { $0.isFavorite }

        if !recentlyWatched.isEmpty {
            section(title: "Recently watched", media: recentlyWatched)
        }

        if !favorites.isEmpty {
            section(title: "Favorites", media: favorites)
        }
    }

    @ViewBuilder
    private func showsView(_ shows: [TVShow]) -> some View {

        let recentlyWatched: [TVShow] = shows
            .filter { !$0.isFavorite }
            .sorted(by: { $0.lastWatched > $1.lastWatched })

        let favorites = shows
            .filter { $0.isFavorite }

        if !recentlyWatched.isEmpty {
            section(title: "Recently watched", media: recentlyWatched)
        }

        if !favorites.isEmpty {
            section(title: "Favorites", media: favorites)
        }
    }

    @ViewBuilder
    private func booksView(_ books: [Book]) -> some View {

        let reading: [Book] = books
            .filter { !$0.isFavorite }
            .filter { $0.reading }

        let recentlyRead = books
            .filter { !$0.isFavorite }
            .filter { !$0.reading }

        let favorites = books
            .filter { $0.isFavorite }

        if !reading.isEmpty {
            section(title: "Reading", media: reading)
        }

        if !recentlyRead.isEmpty {
            section(title: "Recently read", media: recentlyRead)
        }

        if !favorites.isEmpty {
            section(title: "Favorites", media: favorites)
        }
    }

    @ViewBuilder
    private func artistsView(_ artists: [Artist]) -> some View {
        section(title: "Music I'm listening to", media: artists)
    }

    @ViewBuilder
    private func gamesView(_ games: [Game]) -> some View {
        section(title: "Recently played", media: games.sorted(by: { $0.year > $1.year }))
    }

    private func section(title: String, media: [any Media]) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
            MediaContentView(media: media) { item in
                self.selection = item
                self.showDetails = true
            }
        }
        .sheet(isPresented: $showDetails, content: {
            let hasEpisodes = !((selection as? TVShow)?.episodes.isEmpty ?? true)
            MediaDetailView(media: $selection)
                .if(hasEpisodes, transform: { view in
                    view
                        .presentationDetents([.medium, .large])
                })
                .if(!hasEpisodes, transform: { view in
                    view
                        .readSize(onChange: { size in
                            sheetContentHeight = size.height
                        })
                        .presentationDetents([.height(sheetContentHeight)])
                })
        })
    }
}

struct MediaView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            MediaView(mediaType: .music)
                .task {
                    DependencyValues[\.networkService] = .mock(artists: [.kanye], wait: true)
                    DependencyValues[\.persistenceService] = .mock
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
                .environment(\.layoutType, .grid)
        }
    }

    static var previews: some View {
        Preview()
    }
}
