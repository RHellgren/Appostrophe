//
//  OverlaysServiceTests.swift
//  Canvas
//
//  Created by Robin Hellgren on 21/03/2024.
//

@testable import API

import XCTest

final class OverlaysServiceTests: XCTestCase {

    var sut: OverlaysService!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        sut = OverlaysService(session: urlSession)
    }
    
    func testFetchSuccess() async throws {
        MockURLProtocol.requestHandler = { request in
            let apiURL = URL(string: "https://appostropheanalytics.herokuapp.com/scrl/test/overlays")!
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let mockData = MockData().readJSONFile(fileName: "Overlays_mock")

            return (response, mockData)
        }
        
        let response = try await sut.fetch()
        
        XCTAssertEqual(response.title, "Stickers")
        XCTAssertEqual(response.items.count, 74)
        
        let firstItem = try XCTUnwrap(response.items.first)
        XCTAssertEqual(firstItem.id, 268)
        XCTAssertEqual(firstItem.source, "https://scrl-addtext.b-cdn.net/1707669886150-s1.png")
        XCTAssertEqual(firstItem.name, "s1")
        XCTAssertEqual(firstItem.createdAt, "2024-02-11T16:46:18.712Z")
        XCTAssertEqual(firstItem.categoryId, 36)
    }
    
    func testStatusCodeFailure() async throws {
        let statusCode = 404
        MockURLProtocol.requestHandler = { request in
            let apiURL = URL(string: "https://appostropheanalytics.herokuapp.com/scrl/test/overlays")!
            let response = HTTPURLResponse(url: apiURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!

            return (response, nil)
        }
        
        do {
            _ = try await sut.fetch()
            XCTFail("Expected error not success")
        } catch OverlaysServiceError.httpError(let error) {
            let status = try XCTUnwrap(error as? HTTPStatusCode)
            XCTAssertEqual(status, HTTPStatusCode(rawValue: statusCode)!)
        } catch {
            XCTFail("Expected error not thrown")
        }
    }
    
    func testStatusCodeUnknownFailure() async throws {
        let statusCode = 999
        MockURLProtocol.requestHandler = { request in
            let apiURL = URL(string: "https://appostropheanalytics.herokuapp.com/scrl/test/overlays")!
            let response = HTTPURLResponse(url: apiURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!

            return (response, nil)
        }
        
        do {
            _ = try await sut.fetch()
            XCTFail("Expected error not success")
        } catch OverlaysServiceError.failedToMatchHTTPStatusCode {
            // Expected state, no action
        } catch {
            XCTFail("Expected error not thrown")
        }
    }
    
    func testDecodingFailure() async throws {
        MockURLProtocol.requestHandler = { request in
            let apiURL = URL(string: "https://appostropheanalytics.herokuapp.com/scrl/test/overlays")!
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let mockData = Data()

            return (response, mockData)
        }
        
        do {
            _ = try await sut.fetch()
            XCTFail("Expected error not success")
        } catch OverlaysServiceError.decodingError(let error) {
            XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
        } catch {
            XCTFail("Expected error not thrown")
        }
    }
}

