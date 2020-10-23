//
//  PhotosViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class PhotosViewController: UIViewController {
    
    private var photosRequest: FBRequest<Photo>!
    
    var album: Album?
    private var photos = [Photo]()
    private lazy var photosCollection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.prefetchDataSource = self
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    private var hasNext: Bool {
        return photosRequest.hasNext
    }
    
    private var isFetchInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = album?.name
        
        if let album = album {
            photosRequest = PhotoService.shared.photosRequestForAlbum(album)
            loadData()
        }
        layout()
    }
    
    private func loadData() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        photosRequest.fetch { [weak self] result in
            if let self = self {
                switch result {
                case .success(let photos):
                    let isFisrtPage = self.photos.isEmpty
                    self.photos.append(contentsOf: photos)
                    if isFisrtPage {
                        self.photosCollection.reloadData()
                    } else {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: photos)
                        self.photosCollection.insertItems(at: indexPathsToReload)
                    }
                case .failure(let error):
                    print(error)
                }
                self.isFetchInProgress = false
            }
        }
    }
    
    private func layout() {
        view.addSubview(photosCollection)
        NSLayoutConstraint.activate([
            photosCollection.topAnchor.constraint(equalTo: view.topAnchor),
            photosCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photosCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private let photoCellIdentifier: String = "PhotoCell"
    
}

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hasNext {
            return photos.count + 1
        } else {
            return photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollection.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        if let photoCell = cell as? PhotoCell {
            if indexPath.item < photos.count {
                photoCell.photo = photos[indexPath.item]
            } else {
                photoCell.photo = nil
            }
        }
        return cell
    }
        
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: PhotoCell.previewSize)
    }
    
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageController.view.backgroundColor = .systemBackground
        pageController.delegate = self
        pageController.dataSource = self
        let photo = photos[indexPath.item]
        let vc = DetailViewController()
        vc.photo = photo
        pageController.navigationItem.title = photo.name
        pageController.setViewControllers([vc], direction: .forward, animated: false)
        navigationController?.pushViewController(pageController, animated: true)
    }
    
}

extension PhotosViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let detailVC = viewController as? DetailViewController, let currentPhoto = detailVC.photo else { return nil }
        if let index = photos.firstIndex(of: currentPhoto) {
            if index > 0 {
                let photo = photos[index - 1]
                let vc = DetailViewController()
                vc.photo = photo
                return vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let detailVC = viewController as? DetailViewController, let currentPhoto = detailVC.photo else { return nil }
        if let index = photos.firstIndex(of: currentPhoto) {
            if index < photos.count - 1 {
                collectionView(photosCollection, prefetchItemsAt: [IndexPath(item: index + 2, section: 0)])
                photosCollection.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .bottom, animated: false)
                let photo = photos[index + 1]
                let vc = DetailViewController()
                vc.photo = photo
                return vc
            }
        }
        return nil
    }
    
}

extension PhotosViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if hasNext && indexPaths.contains(where: isLoadingCell) {
            loadData()
        }
    }
}

private extension PhotosViewController {
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= photos.count
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = photosCollection.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func calculateIndexPathsToReload(from newPhotos: [Photo]) -> [IndexPath] {
        let startIndex = photos.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
