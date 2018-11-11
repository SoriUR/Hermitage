//
//  MapViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    var location: Location!
    var destRoom: String? {
        didSet {
            calculateBtn.isHidden = destRoom == nil
        }
    }
    
    @IBOutlet private weak var currentRoomLabel: UILabel!
    @IBOutlet private weak var destinationRoomTextField: UITextField!
    @IBOutlet private weak var calculateBtn: UIButton!
    @IBOutlet private weak var mapImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "Map"

        currentRoomLabel.text = "Вы находитесь в комнате \(String(location.room))"

        mapImageView.image = DrawOnImage(startingImage: #imageLiteral(resourceName: "Map_hermitage"))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func createPath(_ sender: Any) {

        showActivity()
        let info = Constants.roomsInfo.first {
            String($0.room) == destRoom
        }
        let params = [
            "destRoomId": String(info!.room),
            "destZoneId": String(info!.zone),
            "startDeviceId": location.combined
        ]
        NetworkManager.shared.request(Constants.URL.calculatePath,
                                      parameters: params) { json, error in
                                        self.stopActivity()
                                        guard let error = error else {
                                            let pathVC = FinalPathViewController()
                                            pathVC.json = json?.result
                                            self.navigationController?.pushViewController(pathVC, animated: true)
                                            return
                                        }
                                        self.showError(error)
        }
    }

    func DrawOnImage(startingImage: UIImage) -> UIImage? {

        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(startingImage.size)

        // Draw the starting image in the current context as background
        startingImage.draw(at: CGPoint.zero)

        // Get the current context
        let context = UIGraphicsGetCurrentContext()!

        context.setStrokeColor(UIColor.red.cgColor)
        context.setAlpha(0.8)
        context.setLineWidth(10.0)
        context.setFillColor(UIColor.red.cgColor)
        context.addEllipse(in: CGRect(x: 592.2, y: 308.4, width: 15, height: 15))
        context.drawPath(using: .fillStroke)

        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Return modified image
        return myImage
    }
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        guard let text = textField.text, text != "" else {
            return true
        }

        destRoom = text

        return true
    }
}
