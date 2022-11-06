//
//  TVShow.swift
//
//
//  Created by ned on 21/05/22.
//

import Foundation

public struct TVShow: Codable, Identifiable, Equatable {
    
    public struct Episode: Codable, Identifiable, Equatable {
        public var id: String { name + episode + lastWatched.description  }
        
        public let episode: String
        public let name: String
        public let parentShowID: String
        public let lastWatched: Date
        
        enum CodingKeys: String, CodingKey {
            case episode, name
            case parentShowID = "parent_show_id"
            case lastWatched = "watched_on"
        }
        
        public init(episode: String, name: String, parentShowID: String, lastWatched: Date) {
            self.episode = episode
            self.name = name
            self.parentShowID = parentShowID
            self.lastWatched = lastWatched
        }
    }
    
    public let id: String
    public let title: String
    public let lastWatched: Date
    public let episode: String
    public var episodes: [Episode]
    public let isFavorite: Bool
    public let img: String

    enum CodingKeys: String, CodingKey {
        case title, episodes
        case id = "guid"
        case episode = "ep"
        case lastWatched = "last_watch"
        case isFavorite = "is_favorite"
        case img = "img_webp"
    }

    public init(id: String, title: String, lastWatched: Date, episode: String, episodes: [Episode], isFavorite: Bool, img: String) {
        self.id = id
        self.title = title
        self.lastWatched = lastWatched
        self.episode = episode
        self.episodes = episodes
        self.isFavorite = isFavorite
        self.img = img
    }
}
