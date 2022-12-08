//
//  PersistenceService.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import Boutique
import DependencyInjection
import Models

class PersistenceService {
    @StoredValue<APIResponse>(key: "cachedResponse")
    var persistedResponse: APIResponse = .empty

    func set(_ response: APIResponse) async throws {
        $persistedResponse.set(response)
    }
}

// MARK: - Dependency

extension DependencyValues {
    private struct PersistenceServiceKey: DependencyKey {
        static var currentValue: PersistenceService = .init()
    }

    var persistenceService: PersistenceService {
        get { Self[PersistenceServiceKey.self] }
        set { Self[PersistenceServiceKey.self] = newValue }
    }
}
