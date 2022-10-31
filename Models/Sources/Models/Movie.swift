//
//  Movie.swift
//
//
//  Created by ned on 19/05/22.
//

import Foundation

public struct Movie: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let lastWatched: Date
    public let isFavorite: Bool
    public let isCinema: Bool
    public let img: String
    public let year: Int

    enum CodingKeys: String, CodingKey {
        case title, year
        case img = "img_webp"
        case id = "guid"
        case isFavorite = "is_favorite"
        case isCinema = "cinema"
        case lastWatched = "last_watch"
    }

    public init(
        id: String,
        title: String,
        lastWatched: Date,
        isFavorite: Bool,
        isCinema: Bool,
        img: String,
        year: Int
    ) {
        self.id = id
        self.title = title
        self.lastWatched = lastWatched
        self.isFavorite = isFavorite
        self.isCinema = isCinema
        self.img = img
        self.year = year
    }
}
