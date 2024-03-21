//
//  OverlaysCollectionCell.swift
//  Canvas
//
//  Created by Robin Hellgren on 20/03/2024.
//

import UIKit

final class OverlaysCollectionCell: UICollectionViewCell {
    
    // MARK: - Subviews

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = Constants.loadingIndicatorColor
        return loadingIndicator
    }()
    
    // MARK: - Initialiser

    override init(frame: CGRect) {
        super.init(frame: frame)
        make()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.stopAnimating()
        imageView.image = nil
    }
    
    // MARK: - Make

    private func make() {
        contentView.addSubview(imageView)
        imageView.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.insets.top),
            imageView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -Constants.insets.bottom),
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.insets.left),
            imageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.insets.right),
            imageView.widthAnchor.constraint(
                equalTo: imageView.heightAnchor),
            
            loadingIndicator.centerXAnchor.constraint(
                equalTo: imageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(
                equalTo: imageView.centerYAnchor),
        ])
    }
    
    // MARK: - Configure

    func configure(
        with viewModel: OverlaysCollectionCellViewModel
    ) {
        if let image = viewModel.image {
            imageView.image = image
        } else {
            loadingIndicator.startAnimating()
        }
    }
}

// MARK: - Constants

extension OverlaysCollectionCell {
    struct Constants {
        static let insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        static let loadingIndicatorColor: UIColor = .white
    }
}

// MARK: - ViewModel

struct OverlaysCollectionCellViewModel {
    let identifier: Int
    let image: UIImage?
}
