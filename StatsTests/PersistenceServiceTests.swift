//
//  PersistenceServiceTests.swift
//  StatsTests
//
//  Created by ned on 01/11/22.
//

import Models
@testable import Stats
import XCTest

@MainActor final class PersistenceServiceTests: XCTestCase {
    let movie: Movie = .inception
    let persistenceService = PersistenceService()

    override func setUp() async throws {
        persistenceService.$persistedResponse.reset()
    }

    func testPersistenceService() async throws {
        XCTAssertTrue(persistenceService.persistedResponse.movies.isEmpty)

        try await persistenceService.set(APIResponse(movies: [movie], tvShows: [], books: [], artists: [], games: []))

        XCTAssertEqual(persistenceService.persistedResponse.movies.count, 1)
        let firstMovie = try XCTUnwrap(persistenceService.persistedResponse.movies.first)
        XCTAssertEqual(firstMovie, movie)
    }
}
