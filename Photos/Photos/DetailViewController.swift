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
            imageWrapperCollection.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }
    private lazy var imageWrapperCollection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .systemBackground
        collection.delegate = self
        collection.dataSource = self
        collection.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collection.register(DetailsCell.self, forCellWithReuseIdentifier: "DetailsCell")
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Any")
        return collection
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
        parent?.navigationItem.title = photo?.name
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        fetchImage()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        imageWrapperCollection.reloadData()
    }
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
            if let imgCell = cell as? ImageCell {
                imgCell.image = image
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailsCell", for: indexPath)
            if let detailsCell = cell as? DetailsCell {
                var details = [Info]()
                if let caption = photo?.name {
                    details.append(("Caption", caption))
                }
                if let date = photo?.createdAt {
                    details.append(("Created At", dateFormatter.string(from: date)))
                }
                detailsCell.info = details
            }
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Any", for: indexPath)
        }
    }
    
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(
                width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        case 1:
            return CGSize(
                width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        default:
            return .zero
        }
    }
    
}
