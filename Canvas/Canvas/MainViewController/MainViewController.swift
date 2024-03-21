//
//  MainViewController.swift
//  Canvas
//
//  Created by Robin Hellgren on 18/03/2024.
//

import UIKit

final class MainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Subviews

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var panels: [UIView] = {
        let panels = [
            UIView(),
            UIView(),
            UIView()
        ]
        panels.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Constants.Panels.backgroundColor
        }
        return panels
    }()
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.Button.title, for: .normal)
        button.titleLabel?.font = Constants.Button.font
        button.backgroundColor = Constants.Button.backgroundColor
        button.layer.cornerRadius = Constants.Button.cornerRadius
        return button
    }()
    
    private var overlays: [OverlayImageView] = []
    private var currentFocus: OverlayImageView? {
        didSet {
            overlays.forEach { $0.isUserInteractionEnabled = false }
            if let currentFocus {
                scrollView.isScrollEnabled = false
                currentFocus.isUserInteractionEnabled = true
            } else {
                scrollView.isScrollEnabled = true
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        make()
    }
    
    // MARK: - Make

    private func make() {
        makeInstall()
        makeInteractions()
        makeConstraints()
        makeStyle()
    }
    
    private func makeInstall() {
        view.addSubview(scrollView)
        view.addSubview(addButton)
        scrollView.addSubview(contentView)
        panels.forEach { contentView.addSubview($0) }
    }
    
    private func makeInteractions() {
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped)))
    }
    
    private func makeConstraints() {
        var panelConstraints: [NSLayoutConstraint] = []
        panels.forEach {
            panelConstraints.append($0.widthAnchor.constraint(
                equalToConstant: Constants.Panels.width))
            panelConstraints.append($0.heightAnchor.constraint(
                equalTo: contentView.heightAnchor))
            panelConstraints.append($0.topAnchor.constraint(
                equalTo: contentView.topAnchor))
            panelConstraints.append($0.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor))
        }

        NSLayoutConstraint.activate([
            scrollView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(
                equalToConstant: Constants.Panels.height),
            
            contentView.topAnchor.constraint(
                equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(
                equalTo: scrollView.heightAnchor),
            
            panels[0].leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor),
            panels[1].leadingAnchor.constraint(
                equalTo: panels[0].trailingAnchor,
                constant: Constants.Panels.spacing),
            panels[2].leadingAnchor.constraint(
                equalTo: panels[1].trailingAnchor,
                constant: Constants.Panels.spacing),
            panels[2].trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor),
            
            addButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addButton.widthAnchor.constraint(
                equalToConstant: Constants.Button.width),
            addButton.heightAnchor.constraint(
                equalToConstant: Constants.Button.height)
        ] + panelConstraints)
    }
    
    private func makeStyle() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    // MARK: - Actions

    @objc
    private func addButtonPressed(
        _ sender: UIButton
    ) {
        let overlaysViewController = OverlaysCollectionViewController(
            selectionCompletion: { [weak self] image in
                self?.addOverlay(for: image)
            }
        )
        let navigationController = UINavigationController(rootViewController: overlaysViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    // MARK: - Adding overlay
    
    private func addOverlay(
        for image: UIImage
    ) {
        let imageView = OverlayImageView(image: image)
        imageView.frame = CGRect(
            origin: CGPoint(
                x: Constants.screenCenter + scrollView.contentOffset.x - (Constants.Overlays.size.width / 2),
                y: contentView.center.y - (Constants.Overlays.size.height / 2)),
            size: Constants.Overlays.size)

        contentView.addSubview(imageView)
        overlays.append(imageView)
        currentFocus = imageView
    }
    
    // MARK: - Touches
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)
        // Remove focus if touch events outside the scrollview is triggered
        currentFocus = nil
    }
    
    @objc
    func scrollViewTapped(_ recogniser: UIGestureRecognizer) {
        let location = recogniser.location(in: scrollView)
        if let overlay = overlays.first(where: { $0.frame.contains(location) }) {
            // OverlayImageView tapped, swap focus
            currentFocus = overlay
        } else {
            // Scrollview tapped, remove focus
            currentFocus = nil
        }
    }
}

// MARK: - Constants

extension MainViewController {
    struct Constants {
        static let backgroundColor: UIColor = .black
        static let screenCenter = UIScreen.main.bounds.width / 2
        
        struct Panels {
            static let width: CGFloat = 250
            static let height: CGFloat = 250
            static let spacing: CGFloat = 1
            static let backgroundColor: UIColor = .white
        }
        struct Button {
            static let width: CGFloat = 200
            static let height: CGFloat = 50
            static let title = "+"
            static let font: UIFont = .preferredFont(forTextStyle: .largeTitle)
            static let backgroundColor: UIColor = .darkGray
            static let cornerRadius: CGFloat = 20
        }
        struct Overlays {
            static let size = CGSize(width: 100, height: 50)
        }
    }
}
