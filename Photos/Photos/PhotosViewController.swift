//
//  PhotosViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class PhotosViewController: UIViewController {
    
    var album: Album?
    private lazy var photosCollection: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = album?.name
        
        layout()
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
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
    }
    
    private let photoCellIdentifier: String = "PhotoCell"
    
}

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollection.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath)
        if let photoCell = cell as? PhotoCell {
            photoCell.photo = album?.photos[indexPath.item]
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
        let photo = album?.photos[indexPath.item]
        let vc = DetailViewController()
        vc.photo = photo
        pageController.navigationItem.title = photo?.name
        pageController.setViewControllers([vc], direction: .forward, animated: false)
        navigationController?.pushViewController(pageController, animated: true)
    }
    
}

extension PhotosViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = album?.photos.firstIndex(where: { $0.name == viewController.title }) {
            if index > 0 {
                let photo = album?.photos[index - 1]
                let vc = DetailViewController()
                vc.photo = photo
                return vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = album?.photos.firstIndex(where: { $0.name == viewController.title }) {
            if index < album!.photos.count - 1 {
                let photo = album?.photos[index + 1]
                let vc = DetailViewController()
                vc.photo = photo
                return vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let detailVC = pageViewController.viewControllers?.first as? DetailViewController {
            pageViewController.navigationItem.title = detailVC.photo?.name
        }
    }
    
}
