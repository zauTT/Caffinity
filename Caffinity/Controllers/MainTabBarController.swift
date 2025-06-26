//
//  MainTabBarController.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 25.06.25.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super .viewDidLoad()
        
        let caffinityVC = UINavigationController(rootViewController: MainViewController())
        caffinityVC.tabBarItem = UITabBarItem(title: "Caffeine", image: UIImage(systemName: "cup.and.saucer.fill"), tag: 0)
        
        let alcoholVC = UINavigationController(rootViewController: AlcoholViewController())
        alcoholVC.tabBarItem = UITabBarItem(title: "Alcohol", image: UIImage(systemName: "wineglass.fill"), tag: 1)
        
        viewControllers = [caffinityVC, alcoholVC]
    }
}
