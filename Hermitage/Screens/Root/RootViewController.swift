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

        let params = [
            "destRoomId": "219",
            "destZoneId": "7",
            "startDeviceId": "7_224_1"
        ]
        NetworkManager.shared.request(Constants.URL.calculatePath,
                                      parameters: params) { _, _ in

        }

        let chatVC = ChatViewController()
        chatVC.tabBarItem = UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
        let navigVC = StartNavigationViewController()
        navigVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        let viewControllerList = [ chatVC, navigVC, profileVC ]
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0) }
    }

}
