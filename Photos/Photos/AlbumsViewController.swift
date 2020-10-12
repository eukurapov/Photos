//
//  ViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    private var albums = [Album]()
    private lazy var albumsCollection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(AlbumCell.self, forCellWithReuseIdentifier: albumCellIdentifier)
        cv.alwaysBounceVertical = true
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        albums = MockData.albums
        
        layout()
    }
    
    private func layout() {
        view.addSubview(albumsCollection)
        NSLayoutConstraint.activate([
            albumsCollection.topAnchor.constraint(equalTo: view.topAnchor),
            albumsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            albumsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumsCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private let albumCellIdentifier: String = "AlbumCell"

}

extension AlbumsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: albumCellIdentifier, for: indexPath)
        if let albumCell = cell as? AlbumCell {
            albumCell.album = albums[indexPath.item]
        }
        return cell
    }
    
}

extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: AlbumCell.coverSize)
    }
    
}

extension AlbumsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotosViewController()
        let album = albums[indexPath.item]
        vc.album = album
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
