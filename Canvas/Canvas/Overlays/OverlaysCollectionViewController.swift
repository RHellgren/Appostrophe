//
//  OverlaysCollectionViewController.swift
//  Canvas
//
//  Created by Robin Hellgren on 20/03/2024.
//

import API
import UIKit

final class OverlaysCollectionViewController: UICollectionViewController {
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constants.Layout.spacing

        // Calculate item size
        let collectionViewWidth = UIScreen.main.bounds.width - (Constants.Layout.contentInset.left + Constants.Layout.contentInset.right)
        let spacing: CGFloat = (Constants.Layout.spacing * (Constants.Layout.itemsPerRow - 1))
        let itemSize: CGFloat = (collectionViewWidth / Constants.Layout.itemsPerRow) - spacing
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        return layout
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = Constants.CloseButton.backgroundColor
        button.layer.cornerRadius = Constants.CloseButton.cornerRadius
        button.frame = CGRect(origin: .zero, size: Constants.CloseButton.size)
        button.setImage(Constants.CloseButton.image, for: .normal)
        button.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        return button
    }()

    private var viewModel: OverlaysCollectionViewModel?
    private var selectionCompletion: ((UIImage) -> Void)?

    // MARK: - Initialiser

    init(
        selectionCompletion: @escaping ((UIImage) -> Void)
    ) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.selectionCompletion = selectionCompletion
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.title

        setupCollectionView()
        setupViewModel()
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavbar()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        collectionView.backgroundColor = Constants.backgroundColor
        collectionView.register(OverlaysCollectionCell.self, forCellWithReuseIdentifier: Constants.reuseIdentifier)
        collectionView.collectionViewLayout = flowLayout
        collectionView.contentInset = Constants.Layout.contentInset
    }
    
    private func setupViewModel() {
        viewModel = OverlaysCollectionViewModel(didUpdateCallback: { indexPath in
            Task { @MainActor [weak self] in
                if let indexPath {
                    self?.collectionView.reloadItems(at: [indexPath])
                } else {
                    self?.collectionView.reloadData()
                }
            }
        })
    }
    
    private func setupNavbar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: Constants.titleColor]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    // MARK: - CollectionView overrides

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.numberOfItemsInSection(section) ?? 0
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cellViewModel = viewModel?.cellViewModel(for: indexPath),
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.reuseIdentifier,
                for: indexPath
              ) as? OverlaysCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: cellViewModel)
        return cell
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let image = viewModel?.image(for: indexPath) else {
            return
        }
        selectionCompletion?(image)
        dismiss(animated: true)
    }
    
    // MARK: - Fetch data
    
    private func fetchData() {
        Task {
            do {
                try await viewModel?.fetchData()
            } catch {
                showError()
            }
        }
    }
    
    // MARK: - Error handling

    @MainActor
    private func showError() {
        let alert = UIAlertController(
            title: Constants.Alert.title,
            message: Constants.Alert.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: Constants.Alert.buttonTitle,
            style: .default
        ))
        self.present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func closePressed(
        _ sender: UINavigationItem
    ) {
        dismiss(animated: true)
    }
}

// MARK: - Constants

extension OverlaysCollectionViewController {
    struct Constants {
        static let reuseIdentifier = "OverlaysCollectionCell"
        static let backgroundColor: UIColor = .black
        static let title = String(localized: "Overlays")
        static let titleColor: UIColor = .white

        struct Layout {
            static let contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            static let itemsPerRow: CGFloat = 4
            static let spacing: CGFloat = 5
        }
        
        struct CloseButton {
            static let backgroundColor = UIColor.darkGray.cgColor
            static let cornerRadius: CGFloat = 15
            static let size = CGSize(width: 30, height: 30)
            static let image = UIImage(systemName: "xmark")
        }
        
        struct Alert {
            static let title = String(localized: "Something went wrong")
            static let message = String(localized: "Unable to fetch overlays")
            static let buttonTitle = String(localized: "OK")
        }
    }
}
