//
//  AppDelegate.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        
        let navigationController = UINavigationController(rootViewController: AlbumsViewController())
        window?.rootViewController = navigationController
        
        return true
    }
    
}
