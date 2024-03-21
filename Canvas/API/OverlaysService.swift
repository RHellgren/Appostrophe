//
//  OverlaysService.swift
//  API
//
//  Created by Robin Hellgren on 20/03/2024.
//

import Foundation

public final class OverlaysService {
        
    private let session: URLSession
    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    public init(
        session: URLSession = .shared
    ) {
        self.session = session
    }
    
    public func fetch(
    ) async throws -> Overlays {
        guard let request = createRequest() else {
            throw OverlaysServiceError.urlParsingFailed
        }

        let (data, response) = try await session.data(for: request)
        
        if let httpStatusError = self.httpStatusError(response: response) {
            throw httpStatusError
        }

        do {
            let responseObject = try decoder.decode([Overlays].self, from: data)
            guard let overlays = responseObject.compactMap({ $0 }).first else {
                throw OverlaysServiceError.parsingError
            }
            return overlays
        } catch let error {
            throw OverlaysServiceError.decodingError(error)
        }

    }
    
    private func createRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "appostropheanalytics.herokuapp.com"
        components.path = "/scrl/test/overlays"

        guard let url = components.url else {
            return nil
        }
        
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    }
    
    private func httpStatusError(
        response: URLResponse?
    ) -> OverlaysServiceError? {
        if let httpResponse = response as? HTTPURLResponse,
            let status = httpResponse.status {
            switch status {
            case .ok:
                return nil

            default:
                return .httpError(status)
            }
        } else {
            return .failedToMatchHTTPStatusCode
        }
    }
}
