//
//  AlbumCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    private var coverImageView = UIImageView()
    private var nameLabel = UILabel()
    private var createdAtLabel = UILabel()
    private var activityIndicator = UIActivityIndicatorView()
    
    var album: Album? {
        didSet {
            guard let album = self.album else { return }
            nameLabel.text = album.name
            createdAtLabel.text = dateFormatter.string(from: album.createdAt)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + TimeInterval.random(in: 0...3)) { [weak self] in
                if let url = album.coverImageUrl, let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.coverImageView.image = UIImage(data: data)
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
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(createdAtLabel)
        
        addSubview(coverImageView)
        addSubview(stackView)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: AlbumCell.coverSize),
            coverImageView.widthAnchor.constraint(equalToConstant: AlbumCell.coverSize),
            
            activityIndicator.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: coverImageView.trailingAnchor, multiplier: 1),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ])
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    static let coverSize: CGFloat = 72
    
}
