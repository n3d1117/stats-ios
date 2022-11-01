//
//  TVShow+Mocks.swift
//  
//
//  Created by ned on 31/10/22.
//

import Foundation
import Models

public extension TVShow {
    static let boris: Self = .init(
        id: "1",
        title: "Boris",
        lastWatched: Date(),
        episode: "S1E1",
        isFavorite: false,
        img: "boris.webp"
    )
}
