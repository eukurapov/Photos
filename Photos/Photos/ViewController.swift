//
//  ViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

class AlbumsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [unowned self] in
            let vc = UIViewController()
            vc.view.backgroundColor = .green
            vc.title = "Photos"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }


}

