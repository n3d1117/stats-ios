//
//  NetworkDataLoader.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Foundation
import DependencyInjection
import Models
import Boutique

@MainActor class NetworkDataLoader: ObservableObject {
    @Dependency(\.networkService) private var networkService
    
    @AsyncStoredValue<APIResponse>(storage: SQLiteStorageEngine.default(appendingPath: "cachedResponse"))
    var cachedResponse: APIResponse = .empty

    @Published private(set) var state: State = .loading

    enum State {
        case success(APIResponse)
        case failed(Error)
        case loading
    }

    func load() async {
        if cachedResponse != .empty {
            state = .success(cachedResponse)
        }
        do {
            let response = try await networkService.loadData()
            state = .success(response)
            try await $cachedResponse.set(response)
        } catch {
            if cachedResponse == .empty {
                state = .failed(error)
            }
        }
    }
}

extension NetworkDataLoader.State: Equatable {
    static func == (lhs: NetworkDataLoader.State, rhs: NetworkDataLoader.State) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success(let lhsValue), .success(let rhsValue)):
            return lhsValue == rhsValue
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
