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
            if view.window != nil {
                imageWrapperCollection.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
        }
    }
    private lazy var imageWrapperCollection: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isPagingEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tableView.separatorColor = .clear
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        tableView.register(DetailsCell.self, forCellReuseIdentifier: "DetailsCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
    }
    
    private func layout() {
        view.addSubview(imageWrapperCollection)
        imageWrapperCollection.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageWrapperCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageWrapperCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageWrapperCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageWrapperCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func fetchImage() {
        guard let photo = self.photo else { return }
        guard image == nil else { return }
        PhotoService.shared.fetchFullSizeImageForPhoto(photo) { [weak self] result in
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
        parent?.navigationItem.title = photo?.name
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        fetchImage()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        imageWrapperCollection.reloadData()
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
            if let imgCell = cell as? ImageCell {
                imgCell.photo = image
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath)
            if let detailsCell = cell as? DetailsCell {
                detailsCell.caption = photo?.name ?? ""
                detailsCell.createdAt = photo?.createdAt ?? Date()
                if let location = photo?.place?.location {
                    detailsCell.position = (lat: location.latitude, lon: location.longitude)
                }
                if let likes = photo?.likes {
                    detailsCell.likesNumber = likes.summary.total
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        default: return UITableView.automaticDimension
        }
    }
    
}
