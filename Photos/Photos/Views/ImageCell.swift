//
//  ImageCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 16.10.2020.
//

import UIKit

class ImageCell: UITableViewCell {
    
    var photo: UIImage? {
        didSet {
            guard let photo = photo else {
                photoView.image = nil
                activityIndicator.startAnimating()
                return
            }
            activityIndicator.stopAnimating()
            photoView.image = photo
            let size = CGSize(width: boundsWidthInSafeArea, height: boundsHeightInSafeArea)
            updateMinZoomScaleForSize(size)
            scrollView.zoomScale = scrollView.minimumZoomScale
            centerImageViewForSize(size)
        }
    }
    private var photoView = UIImageView()
    private var scrollView = UIScrollView()
    private var activityIndicator = UIActivityIndicatorView()
    
    var imageViewTopConstraint: NSLayoutConstraint!
    var imageViewLeadingConstraint: NSLayoutConstraint!
    var imageViewTrailingConstraint: NSLayoutConstraint!
    var imageViewBottomConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layout()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        let doubleTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        doubleTapGestureRecogniser.numberOfTapsRequired = 2
        photoView.addGestureRecognizer(doubleTapGestureRecogniser)
    }
    
    @objc
    private func imageTapped() {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            UIView.animate(withDuration: 0.5) {
                self.scrollView.zoomScale = self.scrollView.maximumZoomScale
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            }
        }
    }
    
    private func layout() {
        scrollView.delegate = self
        scrollView.addSubview(photoView)
        contentView.addSubview(scrollView)
        contentView.addSubview(activityIndicator)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        photoView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewTopConstraint = photoView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewLeadingConstraint = photoView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewTrailingConstraint = photoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        imageViewBottomConstraint = photoView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageViewTopConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
            imageViewBottomConstraint,
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        if let image = photoView.image {
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
        return photoView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageViewForSize(CGSize(width: boundsWidthInSafeArea, height: boundsHeightInSafeArea))
    }
    
    private func centerImageViewForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - photoView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - photoView.frame.width) / 2)
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
