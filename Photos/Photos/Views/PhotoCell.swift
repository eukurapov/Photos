//
//  PhotoCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

import UIKit

class PhotoCell: UICollectionViewCell {
    
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var createdAtLabel = UILabel()
    private var activityIndicator = UIActivityIndicatorView()
    
    var photo: Photo? {
        didSet {
            activityIndicator.startAnimating()
            imageView.image = nil
            guard let photo = self.photo else { return }
            nameLabel.text = photo.name
            createdAtLabel.text = dateFormatter.string(from: photo.createdAt)
            PhotoService.shared.fetchAlbumImageForPhoto(photo) { [weak self] result in
                switch result {
                case .success(let image):
                    self?.activityIndicator.stopAnimating()
                    self?.imageView.image = image
                case .failure(let error):
                    self?.activityIndicator.stopAnimating()
                    self?.imageView.image = UIImage(systemName: "exclamationmark.icloud")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 3
        createdAtLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        createdAtLabel.adjustsFontForContentSizeCategory = true
        createdAtLabel.alpha = 0.7
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    private func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(createdAtLabel)
        
        addSubview(imageView)
        addSubview(stackView)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: PhotoCell.previewSize),
            imageView.widthAnchor.constraint(equalToConstant: PhotoCell.previewSize),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ])
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    static let previewSize: CGFloat = 120
    
}
