//
//  GuidelineView.swift
//  Canvas
//
//  Created by Robin Hellgren on 22/03/2024.
//

import UIKit

final class GuidelineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .yellow
        translatesAutoresizingMaskIntoConstraints = false
        layer.zPosition = .greatestFiniteMagnitude
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
