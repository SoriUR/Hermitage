//
//  FinalPathViewController.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

class FinalPathViewController: UIViewController {

    @IBOutlet private weak var pathColorView: UIView!
    @IBOutlet private weak var mapImageView: UIImageView!

    @IBAction func clearPath() {
        showActivity()

        let params = [
            "pathId": json!.pathId,
        ]

        NetworkManager.shared.request(Constants.URL.clearPath,
                                      parameters: params) { json, error in
                                        self.stopActivity()
                                        guard let error = error else {
                                            self.navigationController?.popToRootViewController(animated: true)
                                            return
                                        }
                                        self.showError(error)


        }
    }

    var json: Path?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        clearPath()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.title = "Ваш маршрут"

        guard let json = json else {
            return
        }

        pathColorView.layer.cornerRadius = pathColorView.bounds.width/2
        pathColorView.clipsToBounds = true
        pathColorView.layer.borderColor = UIColor.black.cgColor
        pathColorView.layer.borderWidth = 2
        pathColorView.backgroundColor = calculateColor(from: json.color)

        var devices = json.devices
        devices.append(json.destDevice)
        mapImageView.image = DrawOnImage(startingImage: #imageLiteral(resourceName: "Map_hermitage"), path: devices)
    }

    private func calculateColor(from string: String) -> UIColor {
        let digits = string.split(separator: " ")
        let red: CGFloat = digits[0] == "0" ? 0 : 1
        let green: CGFloat = digits[1] == "0" ? 0 : 1
        let blue: CGFloat = digits[2] == "0" ? 0 : 1

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private func drawPoint(_ path: String?, _ context: CGContext) {
        // Draw start
        guard let path = path, let (x, y) = calculateCoors(from: path) else { return }

        context.setStrokeColor(UIColor.red.cgColor)
        context.setAlpha(0.8)
        context.setLineWidth(10.0)
        context.setFillColor(UIColor.red.cgColor)
        context.addEllipse(in: CGRect(x: x-7, y: y-7, width: 14, height: 14))
        context.drawPath(using: .fillStroke)
    }

//    private func drawArrow(_ path: String?, _ context: CGContext) {
//        // Draw start
//        guard let path = path, let (x, y) = calculateCoors(from: path) else { return }
//
//        context.move(to: CGPoint(x: x+20, y: y-20))
//        context.addLine(to: CGPoint(x: x, y: y))
//        context.addLine(to: CGPoint(x: x+20, y: y+20))
//        context.setLineWidth(10.0)
//        context.setStrokeColor(UIColor.black.cgColor)
//        context.strokePath()
//    }

    func DrawOnImage(startingImage: UIImage, path: [String]) -> UIImage? {
        UIGraphicsBeginImageContext(startingImage.size)
        startingImage.draw(at: CGPoint.zero)
        let context = UIGraphicsGetCurrentContext()!

        // Draw path
        for (index, node) in path.enumerated()  {
            guard let (x, y) = calculateCoors(from: node) else { continue }

            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.setLineWidth(10.0)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()

        // Draw Start
        drawPoint(path.first, context)

//         Draw arrow
//        drawArrow(path.last, context)

        // Draw last
        drawPoint(path.last, context)

        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return myImage
    }

    private func calculateCoors(from string: String) -> (CGFloat, CGFloat)? {
        guard let location = decodeLocation(string),
            let info = findInfo(by: location),
            let coords = info.coords else {
                return nil
        }

        return coords
    }

    private func findInfo(by location: Location) -> RoomInfo? {
        var result: RoomInfo?
        Constants.roomsInfo.forEach {
            if $0.room == location.room
            && $0.zone == location.zone {
                result = $0
            }
        }
        return result
    }

    func decodeLocation(_ string: String) -> Location? {
        let digits = string.split(separator: "_")
        let zone = Int(String(digits[0]))!
        let room = Int(String(digits[1]))!
        let device = Int(String(digits[2]))!

        return Location(zone: zone, room: room, device: device)
    }

}

extension String {

    var cgFloat: CGFloat? {
        guard let double = Double(self) else {
            return nil
        }
        return CGFloat(double)
    }
}
