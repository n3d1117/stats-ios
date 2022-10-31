//
//  NetworkDataLoader.swift
//  Stats
//
//  Created by ned on 31/10/22.
//

import Foundation
import DependencyInjection
import Models

@MainActor class NetworkDataLoader: ObservableObject {
    @Dependency(\.networkService) private var networkService
    
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
        } catch {
            state = .failed(error)
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
