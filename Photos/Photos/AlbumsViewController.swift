//
//  ViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class AlbumsViewController: UIViewController {
    
    private var albumsRequest: FBRequest<Album>!
    
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
    
    var logoutButton: UIBarButtonItem {
        let item = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(login))
        navigationItem.leftBarButtonItem = item
        item.isEnabled = false
        return item
    }
    
    private var hasNext: Bool {
        return albumsRequest.hasNext
    }
    
    private var isFetchInProgress: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        if PhotoService.shared.isAuthorised {
            configure()
        } else {
            login()
        }
    }
    
    private func configure() {
        refresh()
        layout()
        configureRefreshControl()
    }
    
    private func configureRefreshControl() {
        albumsCollection.refreshControl = UIRefreshControl()
        albumsCollection.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    private func refresh() {
        albumsRequest = PhotoService.shared.albumsRequest()
        if albumsRequest != nil {
            loadData()
        }
    }
    
    private func loadData() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        albumsRequest.fetch { [weak self] result in
            if let self = self {
                switch result {
                case .success(let albums):
                    if self.albumsCollection.refreshControl?.isRefreshing ?? false {
                        self.albums.removeAll(keepingCapacity: true)
                    }
                    let isFisrtPage = self.albums.isEmpty
                    self.albums.append(contentsOf: albums)
                    if isFisrtPage {
                        self.albumsCollection.reloadData()
                    } else {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: albums)
                        self.albumsCollection.reloadItems(at: self.visibleIndexPathsToReload(intersecting: indexPathsToReload))
                    }
                case .failure(let error):
                    print("-- Albums fetching error --\n\(error)")
                }
                self.isFetchInProgress = false
                self.albumsCollection.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func layout() {
        logoutButton.isEnabled = true
        
        view.addSubview(albumsCollection)
        NSLayoutConstraint.activate([
            albumsCollection.topAnchor.constraint(equalTo: view.topAnchor),
            albumsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            albumsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            albumsCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    private func login() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.loginButton.delegate = self
        present(loginVC, animated: true)
    }

    private let albumCellIdentifier: String = "AlbumCell"

}

extension AlbumsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hasNext {
            return albums.count + 1
        } else {
            return albums.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: albumCellIdentifier, for: indexPath)
        if let albumCell = cell as? AlbumCell {
            if indexPath.item < albums.count {
                albumCell.album = albums[indexPath.item]
            } else {
                albumCell.album = nil
            }
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

extension AlbumsViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard result?.isCancelled == false else { return }
        guard result?.grantedPermissions.contains(PhotoService.fbPhotoPermission) ?? false else { return }
        dismiss(animated: true) { [weak self] in
            self?.configure()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        dismiss(animated: true)
        albums.removeAll()
        login()
    }
    
}

extension AlbumsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if hasNext && indexPaths.contains(where: isLoadingCell) {
            loadData()
        }
    }
}

private extension AlbumsViewController {
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= albums.count
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = albumsCollection.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func calculateIndexPathsToReload(from newAlbums: [Album]) -> [IndexPath] {
        let startIndex = albums.count - newAlbums.count
        let endIndex = startIndex + newAlbums.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
