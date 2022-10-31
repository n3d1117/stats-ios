//
//  GamesView.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import SwiftUI
import Models
import DependencyInjection
import Networking

struct GamesView: View {

    @EnvironmentObject var dataLoader: NetworkDataLoader

    var body: some View {
        ZStack {
            switch dataLoader.state {

            case .success(let response):
                ScrollView {
                    gamesView(for: response.games)
                        .padding()
                }

            case .loading:
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Dummy header")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        MoviesGridViewMock()
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

    private func gamesView(for games: [Game]) -> some View {
        VStack(alignment: .leading) {
            Text("Recently played")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            GamesGridView(games: games.sorted(by: { $0.year > $1.year }))
        }
    }
}

struct GamesGridView: View {

    let games: [Game]

    var body: some View {
        GridView {
            ForEach(games) { game in
                MediaGridItemView(
                    title: game.name,
                    subtitle: String(game.year),
                    imageURL: URL(string: (API.baseImageUrl + game.img).urlEncoded),
                    aspectRatio: 0.7,
                    circle: false
                )
            }
        }
    }
}

struct GamesGridView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject private var dataLoader = NetworkDataLoader()

        var body: some View {
            GamesView()
                .task {
                    DependencyValues[\.networkService] = .mock(games: [.gow], wait: true)
                    await dataLoader.load()
                }
                .environmentObject(dataLoader)
        }
    }

    static var previews: some View {
        Preview()
    }
}
