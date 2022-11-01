//
//  Book+Mocks.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Models

public extension Book {
    static let open: Self = .init(
        id: "1",
        title: "Open",
        author: "Andre Agassi",
        isFavorite: false,
        reading: false,
        img: "open-by-andre-agassi-SHlF8.webp"
    )
}
