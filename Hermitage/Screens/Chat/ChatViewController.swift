//
//  CharViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit
import Cartography

class ChatViewController: UIViewController {

    private let tempInfo: [PersonInfo] = [
        PersonInfo(image: #imageLiteral(resourceName: "profile 3"), name :"Маша", message: "Привет, как дела?"),
        PersonInfo(image: #imageLiteral(resourceName: "profile 1"), name :"Иван", message: "Идем на обед?"),
        PersonInfo(image: #imageLiteral(resourceName: "profile 2"), name: "Инна", message: "Документы получила!")
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
        self.title = "Чат"


        let nib = UINib(nibName: CustomTableViewCell.xibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)

        view.addSubview(tableView)
        constrain(tableView, view) {
            $0.center == $1.center
            $0.left == $1.left
            $0.right == $1.right
            $0.bottom == $1.bottom
        }
    }

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath)

        guard let myCell = cell as? CustomTableViewCell else {
            return cell
        }

        myCell.info = tempInfo[indexPath.row]
        return myCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}

extension UIView {

    class var xibName: String {
        return typeName(of: self)
    }

}

public func typeName<T>(of type: T.Type) -> String {
    return String(describing: type)
}

