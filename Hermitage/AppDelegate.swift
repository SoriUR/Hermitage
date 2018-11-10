//
//  AppDelegate.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 09/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .white

        window?.rootViewController = RootViewController()

        return true
    }

}

