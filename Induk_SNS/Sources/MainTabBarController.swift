//
//  AppDelegate.swift
//  Induk_SNS
//
//  Created by 승진김 on 18/12/2018.
//  Copyright © 2018 seungjin. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        // Login 여부가 없을시, User정보가 없을시
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginViewController = LoginController()
                let navigationVC = UINavigationController(rootViewController: loginViewController)
                self.present(navigationVC, animated: true, completion: nil)
            }
            return
        }
        
        setupViewController()
    }
    
    //MARK:- Setup
    func setupViewController()  {
        //home
        let homeVC = templateNaviController(rootViewContoller: HomeController(), unselectedImage: UIImage(named: "home_unselected"), selectedImage: UIImage(named: "home_selected"))
        tabBar.tintColor = .black
        
        let searchVC = templateNaviController(rootViewContoller: UserSearchController(), unselectedImage: UIImage(named: "search_unselected"), selectedImage: UIImage(named: "search_selected"))
        tabBar.tintColor = .black
        
        let plusVC = templateNaviController(rootViewContoller: HomeController(), unselectedImage: UIImage(named: "plus_unselected"), selectedImage: UIImage(named: "plus_unselected"))
        tabBar.tintColor = .black
        
        
        //profile
        let userProfileVC = UserProfileController()
        let userProfileNaviController = UINavigationController(rootViewController: userProfileVC)
        userProfileNaviController.tabBarItem.image = UIImage(named: "profile_unselected")
        userProfileNaviController.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        
        tabBar.tintColor = .black
        
        //UITabBarController에는 [viewcontroller]가 존재해서
        //배열로 관리함
        viewControllers = [homeVC, searchVC, plusVC, userProfileNaviController]
        
        //tabbar Item insets
        guard let items = tabBar.items else { return }
        items.forEach {
            $0.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        }
    }
    
    private func templateNaviController(rootViewContoller: UIViewController = UIViewController(), unselectedImage: UIImage?, selectedImage: UIImage?) -> UINavigationController {
        let viewController = rootViewContoller
        let naviController = UINavigationController(rootViewController: viewController)
        naviController.tabBarItem.image = unselectedImage
        naviController.tabBarItem.selectedImage = selectedImage
        
        return naviController
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let naviController = UINavigationController(rootViewController: photoSelectorController)
            
            present(naviController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}






