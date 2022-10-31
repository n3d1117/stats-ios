//
//  Artist.swift
//
//
//  Created by ned on 21/05/22.
//

public struct Artist: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let img: String

    enum CodingKeys: String, CodingKey {
        case name
        case id = "url"
        case img = "img_webp"
    }

    public init(id: String, name: String, img: String) {
        self.id = id
        self.name = name
        self.img = img
    }
}
