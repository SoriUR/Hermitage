//
//  UIViewController + showError.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error, completion: ((UIAlertAction) -> Void)? = nil ) {
        showError(with: error.localizedDescription)
    }

    func showError(with message: String, completion: ((UIAlertAction) -> Void)? = nil ) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: completion ))
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
