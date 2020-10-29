//
//  LoginViewController.swift
//  Photos
//
//  Created by Eugene Kurapov on 13.10.2020.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    let titleLabel = UILabel()
    let loginButton = FBLoginButton()
    var closeButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.alpha = 0.7
        titleLabel.numberOfLines = 0
        titleLabel.text = "Login to browse your Facebook albums"
        
        if let token = AccessToken.current, !token.isExpired {
            titleLabel.text = "Stay logged in to keep access to photos"
            addCloseButton()
        }
        
        loginButton.permissions = ["user_photos"]
        
        layout()
    }
    
    private func layout() {
        view.addSubview(loginButton)
        view.addSubview(titleLabel)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
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
