@testable import Models
import XCTest

@available(iOS 13.0, *)
final class ModelsTests: XCTestCase {
    let inception: Movie = .init(
        id: "1", title: "Inception", lastWatched: Date(), isFavorite: false, isCinema: false, img: "", year: 2012
    )
    let cinemaMovie: Movie = .init(
        id: "1", title: "Inception", lastWatched: Date(), isFavorite: false, isCinema: true, img: "", year: 2012
    )
    let boris: TVShow = .init(
        id: "1", title: "Boris", lastWatched: Date(), episode: "S1E1", episodes: [], isFavorite: false, img: ""
    )
    let open: Book = .init(id: "1", title: "Open", author: "Andre Agassi", isFavorite: false, addedAt: Date(), reading: false, img: "")
    let radiohead: Artist = .init(id: "1", name: "Radiohead", img: "")
    let gow: Game = .init(id: "1", name: "God of War", year: 2018, img: "")

    func testMovieMediaConformance() throws {
        let inceptionAsMedia: Media = inception
        XCTAssertEqual(inceptionAsMedia.id, inception.id)
        XCTAssertEqual(inceptionAsMedia.title, inception.title)
        XCTAssertEqual(inceptionAsMedia.subtitle, Date().formatted(date: .abbreviated, time: .omitted))
    }

    func testCinemaMovieMediaConformance() throws {
        let cinemaMovieAsMedia: Media = cinemaMovie
        XCTAssertEqual(cinemaMovieAsMedia.subtitle, Date().formatted(date: .abbreviated, time: .omitted) + " 🎬")
    }

    func testTVShowMediaConformance() throws {
        let borisAsMedia: Media = boris
        XCTAssertEqual(borisAsMedia.id, boris.id)
        XCTAssertEqual(borisAsMedia.title, boris.title)
        XCTAssertEqual(borisAsMedia.subtitle, boris.episode)
    }

    func testBookMediaConformance() throws {
        let openAsMedia: Media = open
        XCTAssertEqual(openAsMedia.id, open.id)
        XCTAssertEqual(openAsMedia.title, open.title)
        XCTAssertEqual(openAsMedia.subtitle, open.author)
    }

    func testArtistMediaConformance() throws {
        let radioheadAsMedia: Media = radiohead
        XCTAssertEqual(radioheadAsMedia.id, radiohead.id)
        XCTAssertEqual(radioheadAsMedia.title, radiohead.title)
        XCTAssertEqual(radioheadAsMedia.subtitle, nil)
    }

    func testGameMediaConformance() throws {
        let gowAsMedia: Media = gow
        XCTAssertEqual(gowAsMedia.id, gow.id)
        XCTAssertEqual(gowAsMedia.title, gow.title)
        XCTAssertEqual(gowAsMedia.subtitle, String(gow.year))
    }
}
