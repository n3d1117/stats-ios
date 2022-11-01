//
//  NetworkServiceTests.swift
//  StatsTests
//
//  Created by ned on 31/10/22.
//

import DependencyInjection
import Models
import Networking
@testable import Stats
import XCTest

@MainActor final class NetworkServiceTests: XCTestCase {

    let mockedResponse = APIResponse(movies: [], tvShows: [], books: [], artists: [.kanye], games: [])

    class APIServiceMock: APIService {
        let mockedResponse: APIResponse

        init(mockedResponse: APIResponse) {
            self.mockedResponse = mockedResponse
        }

        override func request<T>(_ method: API.Method, _ endpoint: API.Endpoint) async throws -> T where T: Decodable {
            if let mockedResponse = mockedResponse as? T {
                return mockedResponse
            } else {
                throw StatsError.unknown
            }
        }
    }

    func testNetworkService() async throws {
        let networkService: NetworkService = .init(apiService: APIServiceMock(mockedResponse: mockedResponse))
        let response = try await networkService.loadData()
        XCTAssertEqual(response, mockedResponse)
    }

}
