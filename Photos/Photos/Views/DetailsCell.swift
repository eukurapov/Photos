//
//  DetailsCell.swift
//  Photos
//
//  Created by Eugene Kurapov on 16.10.2020.
//

import UIKit

typealias Info = (name: String, value: String)

class DetailsCell: UICollectionViewCell {
    
    var info = [Info]()
    private lazy var infoTable: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        //addSubview(infoTable)
        contentView.addSubview(infoTable)
        infoTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            infoTable.topAnchor.constraint(equalTo: contentView.topAnchor),
            infoTable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            infoTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            infoTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
}

extension DetailsCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: "detail")
        let detail = info[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.textProperties.numberOfLines = 0
        content.textProperties.lineBreakMode = .byWordWrapping
        content.text = detail.name
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.lineBreakMode = .byWordWrapping
        content.secondaryText = detail.value
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Info"
    }
    
}
