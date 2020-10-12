//
//  DetailViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class DetailViewController: UIViewController {
    
    var photo: Photo? {
        didSet {
            guard let photo = self.photo else { return }
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + TimeInterval.random(in: 0...3)) { [weak self] in
                if let url = photo.imageURL, let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    private var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = photo?.name
        
        layout()
    }
    
    private func layout() {
        view.addSubview(imageView)
        
        // TODO: wrap image view into scroll view
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = true
    }
    
}
