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
    
    func testApiResponseConstructorInjection() async throws {
        let vm = StatsViewModelV2(apiResponse: .empty)
        XCTAssertEqual(vm.apiResponse, .empty)
        
        let nonEmptyVm = StatsViewModelV2(apiResponse: .init(movies: [.inception], tvShows: [], books: [], artists: [], games: []))
        XCTAssertFalse(nonEmptyVm.apiResponse.movies.isEmpty)
        XCTAssertEqual(nonEmptyVm.apiResponse.movies.first, .inception)
    }
    
    func testChartDataCreationForMovies() async throws {
        let sampleDate1: Date = .now
        let sampleDate2: Date = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: -30, to: .now))
        let movie1: Movie = .init(id: "1", title: "Test1", lastWatched: sampleDate1, isFavorite: false, isCinema: false, img: "", year: 2011)
        let movie2: Movie = .init(id: "2", title: "Test2", lastWatched: sampleDate2, isFavorite: false, isCinema: false, img: "", year: 2012)
        
        let vm = StatsViewModelV2(apiResponse: .init(movies: [movie1, movie2], tvShows: [], books: [], artists: [], games: []))
        XCTAssertFalse(vm.chartData.isEmpty)
    
        let expected: [StatsViewModelV2.ChartData] = [
            .init(id: movie1.id, date: movie1.lastWatched, group: .movies),
            .init(id: movie2.id, date: movie2.lastWatched, group: .movies)
        ]
        XCTAssertEqual(vm.chartData, expected)
    }
    
    func testChartDataCreationExcludesMoviesWatchedEarlierThan2021() async throws {
        let sampleDate1: Date = try XCTUnwrap(Calendar.current.date(byAdding: .year, value: -100, to: .now))
        let sampleDate2: Date = .now
        let movie1: Movie = .init(id: "1", title: "Test1", lastWatched: sampleDate1, isFavorite: false, isCinema: false, img: "", year: 2011)
        let movie2: Movie = .init(id: "2", title: "Test2", lastWatched: sampleDate2, isFavorite: false, isCinema: false, img: "", year: 2011)
        
        let vm = StatsViewModelV2(apiResponse: .init(movies: [movie1, movie2], tvShows: [], books: [], artists: [], games: []))
        XCTAssertFalse(vm.chartData.isEmpty)
    
        let expected: [StatsViewModelV2.ChartData] = [
            .init(id: movie2.id, date: movie2.lastWatched, group: .movies)
        ]
        XCTAssertEqual(vm.chartData, expected)
    }
    
    func testChartDataCreationForTVShows() async throws {
        let sampleDate1: Date = .now
        let sampleDate2: Date = try XCTUnwrap(Calendar.current.date(byAdding: .minute, value: -30, to: .now))
        let episodes: [TVShow.Episode] = [
            .init(episode: "Ep1", name: "Name1", parentShowID: "", lastWatched: sampleDate1),
            .init(episode: "Ep2", name: "Name2", parentShowID: "", lastWatched: sampleDate2)
        ]
        let show = TVShow(id: "1", title: "Test1", lastWatched: sampleDate1, episode: "", episodes: episodes, isFavorite: false, img: "")
        
        let vm = StatsViewModelV2(apiResponse: .init(movies: [], tvShows: [show], books: [], artists: [], games: []))
        XCTAssertFalse(vm.chartData.isEmpty)
    
        let expected: [StatsViewModelV2.ChartData] = episodes.map { episode in
                .init(id: episode.id, date: episode.lastWatched, group: .shows)
        }
        XCTAssertEqual(vm.chartData, expected)
    }
    
    func testChartDataCreationExcludesTVShowsEpisodesWatchedEarlierThan2021() async throws {
        let sampleDate1: Date = .now
        let sampleDate2: Date = try XCTUnwrap(Calendar.current.date(byAdding: .year, value: -100, to: .now))
        let episodes: [TVShow.Episode] = [
            .init(episode: "Ep1", name: "Name1", parentShowID: "", lastWatched: sampleDate1),
            .init(episode: "Ep2", name: "Name2", parentShowID: "", lastWatched: sampleDate2)
        ]
        let show = TVShow(id: "1", title: "Test1", lastWatched: sampleDate1, episode: "", episodes: episodes, isFavorite: false, img: "")
        
        let vm = StatsViewModelV2(apiResponse: .init(movies: [], tvShows: [show], books: [], artists: [], games: []))
        XCTAssertFalse(vm.chartData.isEmpty)
    
        let first = try XCTUnwrap(episodes.first)
        let expected: [StatsViewModelV2.ChartData] = [.init(id: first.id, date: first.lastWatched, group: .shows)]
        XCTAssertEqual(vm.chartData, expected)
    }
}
