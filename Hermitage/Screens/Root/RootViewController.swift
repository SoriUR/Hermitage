//
//  RootViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let chatVC = ChatViewController()
        chatVC.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "chat"), tag: 0)
        let navigVC = StartNavigationViewController()
        navigVC.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "internt_web_technology-08-512"), tag: 1)
        let profileVC = FeedViewController()
        profileVC.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "news_215276"), tag: 2)
        let viewControllerList = [ chatVC, navigVC, profileVC ]
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0) }
    }

}
