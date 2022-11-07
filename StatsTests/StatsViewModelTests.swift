//
//  StatsViewModelTests.swift
//  StatsTests
//
//  Created by ned on 05/11/22.
//

import Foundation
@testable import Stats
import XCTest
import Models

@MainActor final class StatsViewModelTests: XCTestCase {
    
    func testChartDataCreationForMovies() async throws {
        let sampleDate1: Date = .now
        let sampleDate2: Date = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: -30, to: .now))
        let movie1: Movie = .init(id: "1", title: "Test1", lastWatched: sampleDate1, isFavorite: false, isCinema: false, img: "", year: 2011)
        let movie2: Movie = .init(id: "2", title: "Test2", lastWatched: sampleDate2, isFavorite: false, isCinema: false, img: "", year: 2012)
        
        let vm = StatsViewModel()
        XCTAssertTrue(vm.globalChartData.isEmpty)
        vm.generateData(with: .init(movies: [movie1, movie2], tvShows: [], books: [], artists: [], games: []))
        XCTAssertFalse(vm.globalChartData.isEmpty)
    
        let expected: [StatsViewModel.ChartData] = [
            .init(id: movie1.id, date: movie1.lastWatched, group: .movies, dataType: .movie(movie1)),
            .init(id: movie2.id, date: movie2.lastWatched, group: .movies, dataType: .movie(movie2))
        ]
        XCTAssertEqual(vm.globalChartData, expected)
    }
    
    func testChartDataCreationExcludesMoviesWatchedEarlierThan2021() async throws {
        let sampleDate1: Date = try XCTUnwrap(Calendar.current.date(byAdding: .year, value: -100, to: .now))
        let sampleDate2: Date = .now
        let movie1: Movie = .init(id: "1", title: "Test1", lastWatched: sampleDate1, isFavorite: false, isCinema: false, img: "", year: 2011)
        let movie2: Movie = .init(id: "2", title: "Test2", lastWatched: sampleDate2, isFavorite: false, isCinema: false, img: "", year: 2011)
        
        let vm = StatsViewModel()
        vm.generateData(with: .init(movies: [movie1, movie2], tvShows: [], books: [], artists: [], games: []))
        XCTAssertFalse(vm.globalChartData.isEmpty)
    
        let expected: [StatsViewModel.ChartData] = [
            .init(id: movie2.id, date: movie2.lastWatched, group: .movies, dataType: .movie(movie2))
        ]
        XCTAssertEqual(vm.globalChartData, expected)
    }
    
    func testChartDataCreationForTVShows() async throws {
        let sampleDate1: Date = .now
        let sampleDate2: Date = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: -30, to: .now))
        let episodes: [TVShow.Episode] = [
            .init(episode: "Ep1", name: "Name1", parentShowID: "", lastWatched: sampleDate1),
            .init(episode: "Ep2", name: "Name2", parentShowID: "", lastWatched: sampleDate2)
        ]
        let show = TVShow(id: "1", title: "Test1", lastWatched: sampleDate1, episode: "", episodes: episodes, isFavorite: false, img: "")
        
        let vm = StatsViewModel()
        vm.generateData(with: .init(movies: [], tvShows: [show], books: [], artists: [], games: []))
        XCTAssertFalse(vm.globalChartData.isEmpty)
    
        let expected: [StatsViewModel.ChartData] = episodes.map { episode in
                .init(id: episode.id, date: episode.lastWatched, group: .shows, dataType: .episode(episode))
        }
        XCTAssertEqual(vm.globalChartData, expected)
    }
    
    func testChartDataCreationExcludesTVShowsEpisodesWatchedEarlierThan2021() async throws {
        let sampleDate1: Date = .now
        let sampleDate2: Date = try XCTUnwrap(Calendar.current.date(byAdding: .year, value: -100, to: .now))
        let episodes: [TVShow.Episode] = [
            .init(episode: "Ep1", name: "Name1", parentShowID: "", lastWatched: sampleDate1),
            .init(episode: "Ep2", name: "Name2", parentShowID: "", lastWatched: sampleDate2)
        ]
        let show = TVShow(id: "1", title: "Test1", lastWatched: sampleDate1, episode: "", episodes: episodes, isFavorite: false, img: "")
        
        let vm = StatsViewModel()
        vm.generateData(with: .init(movies: [], tvShows: [show], books: [], artists: [], games: []))
        XCTAssertFalse(vm.globalChartData.isEmpty)
    
        let first = try XCTUnwrap(episodes.first)
        let expected: [StatsViewModel.ChartData] = [.init(id: first.id, date: first.lastWatched, group: .shows, dataType: .episode(first))]
        XCTAssertEqual(vm.globalChartData, expected)
    }
}
