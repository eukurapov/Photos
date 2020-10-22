//
//  DetailsCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 16.10.2020.
//

import UIKit

typealias Info = (name: String, value: String)

class DetailsCell: UITableViewCell {
    
    private var captionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Caption"
        return label
    }()
    private var captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = label.textColor.withAlphaComponent(0.6)
        return label
    }()
    var caption: String! {
        didSet {
            if caption.isEmpty {
                captionTitleLabel.isHidden = true
                captionLabel.isHidden = true
            } else {
                captionTitleLabel.isHidden = false
                captionLabel.isHidden = false
                captionTitleLabel.text = "Caption"
                captionLabel.text = caption
            }
        }
    }
    private var createdAtTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Created at"
        return label
    }()
    private var createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .right
        label.textColor = label.textColor.withAlphaComponent(0.6)
        return label
    }()
    var createdAt: Date! {
        didSet {
            createdAtLabel.text = dateFormatter.string(from: createdAt)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(captionTitleLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(createdAtTitleLabel)
        contentView.addSubview(createdAtLabel)
        captionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        createdAtTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captionTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            captionTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: captionTitleLabel.trailingAnchor, multiplier: 1),
            
            captionLabel.topAnchor.constraint(equalToSystemSpacingBelow: captionTitleLabel.bottomAnchor, multiplier: 0.5),
            captionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: captionLabel.trailingAnchor, multiplier: 1),
            
            createdAtTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: captionLabel.bottomAnchor, multiplier: 2),
            createdAtTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: createdAtTitleLabel.bottomAnchor, multiplier: 1),
            
            createdAtLabel.centerYAnchor.constraint(equalTo: createdAtTitleLabel.centerYAnchor),
            createdAtLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: createdAtTitleLabel.trailingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: createdAtLabel.trailingAnchor, multiplier: 1)
        ])
    }
    
}
