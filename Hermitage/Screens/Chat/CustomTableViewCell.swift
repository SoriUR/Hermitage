//
//  CustomTableViewCell.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 11/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

struct PersonInfo {
    let image: UIImage
    let name: String
    let message: String
}

class CustomTableViewCell: UITableViewCell {

    static let reuseIdentifier = "customCell"

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!

    var info: PersonInfo? {
        didSet {
            updateUI()
        }
    }

    private func updateUI() {
        guard let info = info else {
            return
        }

        photoImageView.image = info.image
        nameLabel.text = info.name
        messageLabel.text = info.message
    }

}
