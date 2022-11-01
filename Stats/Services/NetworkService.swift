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
