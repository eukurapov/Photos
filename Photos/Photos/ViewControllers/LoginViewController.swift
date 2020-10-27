//
//  LoginViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 13.10.2020.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    let loginButton = FBLoginButton()
    var closeButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        if let token = AccessToken.current, !token.isExpired {
            addCloseButton()
        }
        
        loginButton.permissions = ["user_photos"]
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
    
    private func addCloseButton() {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize.height),
            closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize.width),
        ])
    }
    
    @objc
    private func close() {
        dismiss(animated: true)
    }
    
    private let closeButtonSize: CGSize = CGSize(width: 40, height: 40)
    
}
