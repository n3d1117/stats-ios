//
//  APIService.swift
//
//
//  Created by ned on 31/10/22.
//

import Foundation

open class APIService {
    public init() {}

    private var decoder: JSONDecoder {
        let decoder: JSONDecoder = .init()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    open func request<T: Decodable>(_ method: API.Method, _ endpoint: API.Endpoint) async throws -> T {
        let request = API.generateRequest(method, endpoint)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(T.self, from: data)
    }
}
