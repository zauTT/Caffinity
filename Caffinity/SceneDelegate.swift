//
//  SceneDelegate.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible()
        
        if CommandLine.arguments.contains("--uitesting") {
            UserDefaults.standard.removeObject(forKey: "caffeineEntries")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

