//
//  UIViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit
import Cartography

extension UIViewController {
    func showActivity() {
        DispatchQueue.main.async {
             self.view.isUserInteractionEnabled = false

            let loadingView: UIView = UIView()
            loadingView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5049764555)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            loadingView.tag = 228

            let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
            actInd.style = .whiteLarge
            actInd.startAnimating()




             self.view.addSubview(loadingView)
            loadingView.addSubview(actInd)
            constrain(loadingView, actInd, self.view) {
                $0.center == $2.center
                $0.width == 80
                $0.height == 80

                $1.center == $0.center
            }
        }
    }

    func stopActivity() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.view.subviews.forEach {
                if $0.tag == 228 {
                    $0.removeFromSuperview()
                }
            }
        }
    }
}

