//
//  PersistentService+Mock.swift
//  Stats
//
//  Created by ned on 01/11/22.
//

import Models

extension PersistenceService {

    class Mock: PersistenceService {
        override var persistedResponse: APIResponse { .empty }
        override func set(_ response: APIResponse) async throws { }
    }

    static let mock: PersistenceService = Mock()
}
