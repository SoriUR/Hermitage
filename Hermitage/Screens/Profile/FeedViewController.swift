//
//  ProfileViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit
import Cartography

struct NewsInfo {
    let image: UIImage
    let message: String
}

class FeedViewController: UIViewController {

    private let tempInfo: [NewsInfo] = [
        NewsInfo(image: #imageLiteral(resourceName: "prw-3"), message: "Achilles the Cat’s Prediction for Morocco v. Iran"),
        NewsInfo(image: #imageLiteral(resourceName: "prw-2"), message: "Rembrandt’s Masterpieces Make a Triumphant Return to the Hermitage"),
        NewsInfo(image: #imageLiteral(resourceName: "prw"), message: "General Meeting of the Union of Museums of Russia")
    ]

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()


        view.backgroundColor = .white
        self.title = "Feed/News"


        let nib = UINib(nibName: FeedTableViewCell.xibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FeedTableViewCell.reuseIdentifier)

        view.addSubview(tableView)
        constrain(tableView, view) {
            $0.center == $1.center
            $0.left == $1.left
            $0.right == $1.right
            $0.bottom == $1.bottom
        }
    }

}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseIdentifier, for: indexPath)

        guard let myCell = cell as? FeedTableViewCell else {
            return cell
        }

        myCell.info = tempInfo[indexPath.row]
        return myCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
