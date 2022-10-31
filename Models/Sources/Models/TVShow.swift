//
//  TVShow.swift
//
//
//  Created by ned on 21/05/22.
//

import Foundation

public struct TVShow: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let lastWatched: Date
    public let episode: String
    public let isFavorite: Bool
    public let img: String

    enum CodingKeys: String, CodingKey {
        case title
        case id = "guid"
        case episode = "ep"
        case lastWatched = "last_watch"
        case isFavorite = "is_favorite"
        case img = "img_webp"
    }

    public init(id: String, title: String, lastWatched: Date, episode: String, isFavorite: Bool, img: String) {
        self.id = id
        self.title = title
        self.lastWatched = lastWatched
        self.episode = episode
        self.isFavorite = isFavorite
        self.img = img
    }
}
