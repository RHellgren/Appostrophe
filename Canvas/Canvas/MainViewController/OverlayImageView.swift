//
//  OverlayImageView.swift
//  Canvas
//
//  Created by Robin Hellgren on 21/03/2024.
//

import UIKit

final class OverlayImageView: UIImageView {
        
    override var isUserInteractionEnabled: Bool {
        didSet {
            if isUserInteractionEnabled {
                self.layer.borderWidth = Constants.borderWidth
                self.layer.borderColor = Constants.borderColor
            } else {
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    // MARK: - Initialiser

    override init(
        image: UIImage?
    ) {
        super.init(image: image)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Constants

extension OverlayImageView {
    struct Constants {
        static let borderWidth: CGFloat = 2
        static let borderColor: CGColor = UIColor.blue.cgColor
    }
}
