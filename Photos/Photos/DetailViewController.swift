//
//  DetailViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class DetailViewController: UIViewController {
    
    var photo: Photo?
    private var image: UIImage? {
        didSet {
            guard let image = image else {
                imageView.image = nil
                activityIndicator.startAnimating()
                return
            }
            activityIndicator.stopAnimating()
            imageView.image = image
            let size = CGSize(width: boundsWidthInSafeArea, height: boundsHeightInSafeArea)
            updateMinZoomScaleForSize(size)
            scrollView.zoomScale = scrollView.minimumZoomScale
            centerImageViewForSize(size)
        }
    }
    private var imageView = UIImageView()
    private var scrollView = UIScrollView()
    private var activityIndicator = UIActivityIndicatorView()
    
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
    private var imageViewTrailingConstraint: NSLayoutConstraint!
    private var imageViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parent?.navigationItem.title = photo?.name
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        
        layout()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    private func layout() {
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            imageViewTopConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
            imageViewBottomConstraint,
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func fetchImage() {
        guard let photo = self.photo else { return }
        PhotoService.shared.fetchAlbumImageForPhoto(photo) { [weak self] result in
            switch result {
            case .success(let image):
                self?.image = image
            case .failure(let error):
                self?.image = UIImage(systemName: "exclamationmark.icloud")
                print(error.localizedDescription)
            }
        }
    }
    
    @objc
    private func share() {
        guard let image = image else { return }
        let ac = UIActivityViewController(activityItems: [image, photo?.name ?? ""], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnTap = true
        fetchImage()
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        if let image = imageView.image {
            let widthScale = size.width / image.size.width
            let heightScale = size.height / image.size.height
            let minScale = min(widthScale, heightScale)
            
            scrollView.minimumZoomScale = minScale
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            let insets = self.view.safeAreaInsets
            let size = CGSize(
                width: size.width - insets.left - insets.right,
                height: size.height - insets.top - insets.bottom)
            self.updateMinZoomScaleForSize(size)
            self.centerImageViewForSize(size)
        }
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageViewForSize(CGSize(width: boundsWidthInSafeArea, height: boundsHeightInSafeArea))
    }
    
    private func centerImageViewForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        view.layoutIfNeeded()
    }
    
    private var boundsWidthInSafeArea: CGFloat {
        return view.bounds.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right
    }
    
    private var boundsHeightInSafeArea: CGFloat {
        return view.bounds.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
    }
    
}
