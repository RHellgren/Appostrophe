//
//  OverlaysCollectionViewModel.swift
//  Canvas
//
//  Created by Robin Hellgren on 20/03/2024.
//

import API
import UIKit

final class OverlaysCollectionViewModel {
    
    private let service = OverlaysService()
    private let didUpdateCallback: ((IndexPath?) -> Void)?
	private let imagesQueue = DispatchQueue(label: "images_queue", attributes: .concurrent)

    private var overlays: Overlays?
    private var images: [Int: UIImage] = [:]
    
    // MARK: - Initialiser

    init(
        didUpdateCallback: ((IndexPath?) -> Void)?
    ) {
        self.didUpdateCallback = didUpdateCallback
    }
    
    // MARK: - Fetch image
    
    private func fetchImage(
        for indexPath: IndexPath
    ) {
        guard let overlay = overlays?.items[safe: indexPath.row],
              let url = URL(string: overlay.source) else {
            return
        }
        
        Task {
            guard let (data, _) = try? await URLSession.shared.data(for: URLRequest(url: url)),
                  let image = UIImage(data: data) else {
                return
            }
            
            imagesQueue.async(flags: .barrier) { [weak self] in
                self?.images[overlay.id] = image
            }
            didUpdateCallback?(indexPath)
        }
    }
    
    // MARK: - Public interface

    func fetchData() async throws {
        let overlays = try await service.fetch()
        self.overlays = overlays
        didUpdateCallback?(nil)
    }
    
    func numberOfItemsInSection(
        _ section: Int
    ) -> Int? {
        overlays?.items.count
    }
    
    func cellViewModel(
        for indexPath: IndexPath
    ) -> OverlaysCollectionCellViewModel? {
        guard let overlay = overlays?.items[safe: indexPath.row] else {
            return nil
        }

        return OverlaysCollectionCellViewModel(
            identifier: overlay.id,
            image: image(for: indexPath))
    }
    
    func image(
        for indexPath: IndexPath
    ) -> UIImage? {
        guard let overlay = overlays?.items[safe: indexPath.row] else {
            return nil
        }
        
        var image: UIImage?
        imagesQueue.sync {
            image = images[overlay.id]
        }
        
        if image == nil {
            fetchImage(for: indexPath)
        }
        
        return image
    }
}

