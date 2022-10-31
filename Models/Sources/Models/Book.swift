//
//  Book.swift
//
//
//  Created by ned on 21/05/22.
//

public struct Book: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let author: String
    public let isFavorite: Bool
    public let reading: Bool
    public let img: String

    enum CodingKeys: String, CodingKey {
        case title, author, reading
        case id = "url"
        case isFavorite = "is_favorite"
        case img = "img_webp"
    }

    public init(id: String, title: String, author: String, isFavorite: Bool, reading: Bool, img: String) {
        self.id = id
        self.title = title
        self.author = author
        self.isFavorite = isFavorite
        self.reading = reading
        self.img = img
    }
}
