//
//  Movie+Mocks.swift
//  
//
//  Created by ned on 31/10/22.
//

import Foundation
import Models

public extension Movie {
    static let inception: Self = .init(
        id: "1",
        title: "Inception",
        lastWatched: Date(),
        isFavorite: true,
        isCinema: false,
        img: "inception.webp",
        year: 2_010
    )

    static let donnieDarko: Self = .init(
        id: "2",
        title: "Donnie Darko",
        lastWatched: Date(),
        isFavorite: true,
        isCinema: false,
        img: "donnie_darko.webp",
        year: 2_001
    )

    static let blonde: Self = .init(
        id: "3",
        title: "Blonde",
        lastWatched: Date(),
        isFavorite: false,
        isCinema: false,
        img: "blonde.webp",
        year: 2_022
    )

    static let uncharted: Self = .init(
        id: "4",
        title: "Uncharted",
        lastWatched: Date(),
        isFavorite: false,
        isCinema: true,
        img: "uncharted.webp",
        year: 2_022
    )
}
