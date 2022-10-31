//
//  APIResponse.swift
//
//
//  Created by ned on 19/05/22.
//

public struct APIResponse: Codable {
    public let movies: [Movie]
    public let tvShows: [TVShow]
    public let books: [Book]
    public let artists: [Artist]
    public let games: [Game]

    enum CodingKeys: String, CodingKey {
        case movies, books
        case tvShows = "shows"
        case artists = "spotify"
        case games = "videogames"
    }

    public init(movies: [Movie], tvShows: [TVShow], books: [Book], artists: [Artist], games: [Game]) {
        self.movies = movies
        self.tvShows = tvShows
        self.books = books
        self.artists = artists
        self.games = games
    }
}

extension APIResponse: Equatable {
    public static func == (lhs: APIResponse, rhs: APIResponse) -> Bool {
        lhs.movies == rhs.movies &&
        lhs.tvShows == rhs.tvShows &&
        lhs.books == rhs.books &&
        lhs.artists == rhs.artists &&
        lhs.games == rhs.games
    }
}
