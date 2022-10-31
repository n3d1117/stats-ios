//
//  Game.swift
//
//
//  Created by ned on 21/05/22.
//

public struct Game: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let year: Int
    public let img: String

    enum CodingKeys: String, CodingKey {
        case name, year
        case id = "url"
        case img = "img_webp"
    }
    
    public init(id: String, name: String, year: Int, img: String) {
        self.id = id
        self.name = name
        self.year = year
        self.img = img
    }
}
