//
//  NetworkDataLoader.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import DependencyInjection
import Foundation
import Models

@MainActor class NetworkDataLoader: ObservableObject {
    @Dependency(\.networkService) private var networkService
    @Dependency(\.persistenceService) private var persistenceService

    @Published private(set) var state: State = .loading

    enum State {
        case success(APIResponse)
        case failed(Error)
        case loading
    }

    func load() async {
        do {
            let response = try await networkService.loadData()
            state = .success(response)
            try await persistenceService.set(response)
        } catch {
            let cachedResponse = persistenceService.persistedResponse
            if cachedResponse == .empty {
                state = .failed(error)
            } else {
                state = .success(cachedResponse)
            }
        }
    }
}

// MARK: - Equatable conformance

extension NetworkDataLoader.State: Equatable {
    static func == (lhs: NetworkDataLoader.State, rhs: NetworkDataLoader.State) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.success(lhsValue), .success(rhsValue)):
            return lhsValue == rhsValue
        case let (.failed(lhsError), .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
