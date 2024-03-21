//
//  MockURLProtocol.swift
//  CanvasTests
//
//  Created by Robin Hellgren on 21/03/2024.
//

import Foundation

class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        true
    }
    
    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let requestHandler = MockURLProtocol.requestHandler else {
            fatalError("RequestHandler is not set.")
        }
        
        do {
            let (response, data) = try requestHandler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
