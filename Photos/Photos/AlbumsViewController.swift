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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        if let token = AccessToken.current, !token.isExpired {
            getData()
            layout()
        } else {
            login()
        }
    }
    
    private func getData() {
        PhotoService.shared.fetchAlbums { [weak self] result in
            switch result {
            case .success(let albums):
                self?.albums = albums
                self?.albumsCollection.reloadData()
            case .failure(let error):
                print("-- Albums fetching error --\n\(error.localizedDescription)")
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

extension AlbumsViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard result?.isCancelled == false else { return }
        guard result?.grantedPermissions.contains(PhotoService.fbPhotoPermission) ?? false else { return }
        dismiss(animated: true) { [weak self] in
            self?.getData()
            self?.layout()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        dismiss(animated: true)
        albums.removeAll()
        login()
    }
    
}
