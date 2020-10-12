//
//  PhotoCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var nameLabel = UILabel()
    var createdAtLabel = UILabel()
    
    var photo: Photo? {
        didSet {
            guard let photo = self.photo else { return }
            nameLabel.text = photo.name
            createdAtLabel.text = dateFormatter.string(from: photo.createdAt)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + TimeInterval.random(in: 0...3)) { [weak self] in
                if let url = photo.imageURL, let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        createdAtLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        createdAtLabel.alpha = 0.7
        
        translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(createdAtLabel)
        
        addSubview(imageView)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: PhotoCell.previewSize),
            imageView.widthAnchor.constraint(equalToConstant: PhotoCell.previewSize),
            
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ])
    }
    
    static let previewSize: CGFloat = 120
    
}
