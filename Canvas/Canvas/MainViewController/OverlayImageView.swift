//
//  OverlayImageView.swift
//  Canvas
//
//  Created by Robin Hellgren on 21/03/2024.
//

import UIKit

final class OverlayImageView: UIImageView {
    
    private var localTouchPoint: CGPoint?
    
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
    
    // MARK: - Touch handling
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        self.localTouchPoint = touches.first?.preciseLocation(in: self)
    }

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesMoved(touches, with: event)
        guard let location = touches.first?.location(in: self.superview),
              let localTouchPoint = self.localTouchPoint
        else {
            return
        }
        self.frame.origin = CGPoint(
            x: location.x - localTouchPoint.x,
            y: location.y - localTouchPoint.y
        )
    }

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)
        self.localTouchPoint = nil
    }
}

// MARK: - Constants

extension OverlayImageView {
    struct Constants {
        static let borderWidth: CGFloat = 2
        static let borderColor: CGColor = UIColor.blue.cgColor
    }
}
