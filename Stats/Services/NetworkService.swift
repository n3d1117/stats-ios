//
//  NetworkService.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Networking
import Models
import DependencyInjection

class NetworkService {
    private let apiService: APIService = APIService()

    func loadData() async throws -> APIResponse {
        try await apiService.request(.GET, .data)
    }
}

// MARK: - Dependency
extension DependencyValues {
    private struct NetworkServiceKey: DependencyKey {
        static var currentValue: NetworkService = NetworkService()
    }

    var networkService: NetworkService {
        get { Self[NetworkServiceKey.self] }
        set { Self[NetworkServiceKey.self] = newValue }
    }
}

// MARK: - Mock
extension NetworkService {

    class Mock: NetworkService {

        // swiftlint:disable nesting
        enum MockType {
            case mockedResponse(APIResponse)
            case throwError(Error)
        }

        private let mockType: MockType
        private let wait: Bool

        init(with mockType: MockType, wait: Bool) {
            self.mockType = mockType
            self.wait = wait
        }

        override func loadData() async throws -> APIResponse {
            switch mockType {
            case .mockedResponse(let mockedResponse):
                if wait { try await Task.sleep(nanoseconds: 2_000_000_000) }
                return mockedResponse
            case .throwError(let error):
                if wait { try await Task.sleep(nanoseconds: 2_000_000_000) }
                throw error
            }
        }
    }

    static func mock(
        movies: [Movie] = [],
        shows: [TVShow] = [],
        books: [Book] = [],
        artists: [Artist] = [],
        games: [Game] = [],
        wait: Bool = false
    ) -> NetworkService {
        Mock(with: .mockedResponse(
            .init(movies: movies, tvShows: shows, books: books, artists: artists, games: games)
        ), wait: wait)
    }

    static func error(with error: StatsError, wait: Bool = false) -> NetworkService {
        Mock(with: .throwError(error), wait: wait)
    }
}
