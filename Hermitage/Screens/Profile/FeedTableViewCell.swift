//
//  FeedTableViewCell.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 11/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    static let reuseIdentifier = "feedCell"

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!

    var info: NewsInfo? {
        didSet {
            updateUI()
        }
    }

    private func updateUI() {
        guard let info = info else {
            return
        }

        photoImageView.image = info.image
        messageLabel.text = info.message
    }
    
}
