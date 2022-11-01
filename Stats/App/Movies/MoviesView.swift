//
//  MoviesView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import Models
import DependencyInjection
import Networking
import NukeUI

struct MoviesView: View {

    @EnvironmentObject var dataLoader: NetworkDataLoader
    
    @Environment(\.listLayout) var listLayout

    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    moviesView(for: response.movies)
                        .padding()
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

    private func moviesView(for movies: [Movie]) -> some View {

        let recentlyWatched: [Movie] = movies
            .filter { !$0.isFavorite }
            .sorted(by: { $0.lastWatched > $1.lastWatched })

        let favorites = movies.filter { $0.isFavorite }

        return VStack(spacing: 30) {

            if !recentlyWatched.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recently watched")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    MoviesGridView(movies: recentlyWatched)
                }
            }

            if !favorites.isEmpty {
                VStack(alignment: .leading) {
                    Text("Favorites")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    MoviesGridView(movies: favorites)
                }
            }
        }.animation(.default, value: listLayout)
    }
}

struct MoviesGridView: View {

    let movies: [Movie]
    
    @Environment(\.listLayout) var listLayout

    var body: some View {
        ZStack {
            if !listLayout {
                GridView {
                    ForEach(movies) { movie in
                        MediaGridItemView(
                            title: movie.title,
                            subtitle: String(movie.year) + (movie.isCinema ? " 🎬" : ""),
                            imageURL: URL(string: (API.baseImageUrl + movie.img).urlEncoded),
                            aspectRatio: 0.7,
                            circle: false
                        )
                    }
                }
            } else {
                LazyVStack {
                    ForEach(movies) { movie in
                        MediaListItemView(
                            title: movie.title,
                            subtitle: String(movie.year) + (movie.isCinema ? " 🎬" : ""),
                            imageURL: URL(string: (API.baseImageUrl + movie.img).urlEncoded),
                            aspectRatio: 0.7,
                            circle: false
                        )
                    }
                }
            }
        }
    }
}

struct MoviesView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            MoviesView()
                .task {
                    DependencyValues[\.networkService] = .mock(movies: [.inception, .donnieDarko, .blonde, .uncharted])
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
                .environment(\.listLayout, true)
        }
    }

    static var previews: some View {
        Preview()
    }
}

struct MoviesGridViewMock: View {
    var body: some View {
        GridView {
            ForEach(0..<30, id: \.self) { _ in
                MediaGridItemView.mock
            }
        }
    }
}

struct MoviesListViewMock: View {
    var body: some View {
        VStack {
            ForEach(0..<30, id: \.self) { _ in
                MediaListItemView.mock
            }
        }
    }
}
