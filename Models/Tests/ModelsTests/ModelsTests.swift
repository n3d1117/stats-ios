@testable import Models
import XCTest

@available(iOS 13.0, *)
final class ModelsTests: XCTestCase {
    
    let inception: Movie = Movie(id: "1", title: "Inception", lastWatched: Date(), isFavorite: false, isCinema: false, img: "", year: 2012)
    let cinemaMovie: Movie = Movie(id: "1", title: "Inception", lastWatched: Date(), isFavorite: false, isCinema: true, img: "", year: 2012)
    let boris: TVShow = TVShow(id: "1", title: "Boris", lastWatched: Date(), episode: "S1E1", isFavorite: false, img: "")
    let open: Book = Book(id: "1", title: "Open", author: "Andre Agassi", isFavorite: false, reading: false, img: "")
    let radiohead: Artist = Artist(id: "1", name: "Radiohead", img: "")
    let gow: Game = Game(id: "1", name: "God of War", year: 2_018, img: "")
    
    func testMovieMediaConformance() throws {
        let inceptionAsMedia: Media = inception
        XCTAssertEqual(inceptionAsMedia.id, inception.id)
        XCTAssertEqual(inceptionAsMedia.title, inception.title)
        XCTAssertEqual(inceptionAsMedia.subtitle, String(inception.year))
    }
    
    func testCinemaMovieMediaConformance() throws {
        let cinemaMovieAsMedia: Media = cinemaMovie
        XCTAssertEqual(cinemaMovieAsMedia.subtitle, String(cinemaMovie.year) + " 🎬")
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
        let gowAsMedia: Game = gow
        XCTAssertEqual(gowAsMedia.id, gow.id)
        XCTAssertEqual(gowAsMedia.title, gow.title)
        XCTAssertEqual(gowAsMedia.subtitle, String(gow.year))
    }
}
