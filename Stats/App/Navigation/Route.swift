//
//  Route.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

enum Route: Hashable, CaseIterable {
    case movies, tvShows, books, music, games

    var label: String {
        switch self {
        case .movies: return "Movies"
        case .tvShows: return "TV Shows"
        case .books: return "Books"
        case .music: return "Music"
        case .games: return "Games"
        }
    }

    var image: String {
        switch self {
        case .movies: return "film"
        case .tvShows: return "play.tv"
        case .books: return "book"
        case .music: return "music.mic"
        case .games: return "gamecontroller"
        }
    }
}
