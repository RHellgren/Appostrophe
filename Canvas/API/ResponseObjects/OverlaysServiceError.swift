//
//  OverlaysServiceError.swift
//  API
//
//  Created by Robin Hellgren on 20/03/2024.
//

import Foundation

public enum OverlaysServiceError: Error {
    case urlParsingFailed
    case httpError(Error)
    case failedToMatchHTTPStatusCode
    case decodingError(Error)
    case parsingError
}
