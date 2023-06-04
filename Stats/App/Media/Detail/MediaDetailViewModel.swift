//
//  MediaDetailViewModel.swift
//  Stats
//
//  Created by ned on 03/12/22.
//

import DominantColor
import Foundation
import Nuke
import SwiftUI
import Models

@MainActor final class MediaDetailViewModel: ObservableObject {
    @Published private(set) var dominantColor: Color = .indigo

    func extractDominantColor(for imageURL: URL) async {
        do {
            let image = try await ImagePipeline.shared.image(for: imageURL).image
            if let primaryDominantColor = image.dominantColors().first {
                dominantColor = Color(primaryDominantColor)
            }
        } catch {
            print(error)
        }
    }
    
    func extractUrl(from media: Media) -> URL? {
        var url: URL?

        if let movie = media as? Movie {
            if movie.id.hasPrefix("https") {
                url = URL(string: movie.id)
            } else {
                url = URL(string: "https://www.themoviedb.org/movie/\(movie.id)")
            }
        } else if let show = media as? TVShow {
            url = URL(string: "https://www.themoviedb.org/tv/\(show.id)")
        } else if let book = media as? Book {
            url = URL(string: book.id)
        } else if let artist = media as? Artist {
            url = URL(string: artist.id)
        } else if let game = media as? Game {
            url = URL(string: game.id)
        }

        return url
    }
}
