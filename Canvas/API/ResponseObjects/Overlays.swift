//
//  Overlays.swift
//  API
//
//  Created by Robin Hellgren on 20/03/2024.
//

import Foundation

public struct Overlays: Codable {
    let title: String
    public let items: [Overlay]
}

public struct Overlay: Codable {
    public let id: Int
    public let source: String
    
    let name: String
    let createdAt: String
    let categoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case source = "source_url"
        case name = "overlay_name"
        case createdAt = "created_at"
        case categoryId = "category_id"
    }
}
