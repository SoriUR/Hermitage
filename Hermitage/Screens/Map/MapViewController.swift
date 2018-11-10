//
//  MapViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    var location: Location?
    var isTracking = false
    
    @IBOutlet private weak var currentRoomLabel: UILabel!
    @IBOutlet private weak var destinationRoomTextField: UITextField!
    @IBOutlet private weak var calculateBtn: UIButton!
    @IBOutlet private weak var colorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "Map"

        currentRoomLabel.text = "Вы находитесь в комнате \(String(location!.room))"
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        isTracking = false
    }

    @IBAction func createPath(_ sender: Any) {

        showActivity()
        let params = [
            "destRoomId": "219",
            "destZoneId": "7",
            "startDeviceId": "7_224_1"
        ]
        NetworkManager.shared.request(Constants.URL.calculatePath,
                                      parameters: params) { json, error in
                                        self.stopActivity()
                                        print(json)
        }
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        calculateBtn.isHidden = false
//        colorLabel.isHidden = false
        textField.resignFirstResponder()
        return true
    }
}
