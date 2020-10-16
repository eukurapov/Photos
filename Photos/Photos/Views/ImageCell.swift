//
//  ImageCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 16.10.2020.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var image: UIImage? {
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
    
    var imageViewTopConstraint: NSLayoutConstraint!
    var imageViewLeadingConstraint: NSLayoutConstraint!
    var imageViewTrailingConstraint: NSLayoutConstraint!
    var imageViewBottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    private func layout() {
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        addSubview(scrollView)
        addSubview(activityIndicator)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageViewTopConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
            imageViewBottomConstraint,
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        if let image = imageView.image {
            let widthScale = size.width / image.size.width
            let heightScale = size.height / image.size.height
            let minScale = min(widthScale, heightScale)
            
            scrollView.minimumZoomScale = minScale
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ImageCell: UIScrollViewDelegate {
    
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
        layoutIfNeeded()
    }
    
    private var boundsWidthInSafeArea: CGFloat {
        return bounds.size.width - safeAreaInsets.left - safeAreaInsets.right
    }
    
    private var boundsHeightInSafeArea: CGFloat {
        return bounds.size.height - safeAreaInsets.top - safeAreaInsets.bottom
    }
    
}
