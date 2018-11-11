//
//  RoomInfo.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 11/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import UIKit

struct RoomInfo: Codable {
    let zone: Int
    let room: Int
    let center: String // "Float, Float"
}

extension RoomInfo {
    var coords: (CGFloat, CGFloat)? {
        let fIndex = center.index(center.startIndex, offsetBy: 5)
        let sIndex = center.index(fIndex, offsetBy: 2)
        let xStr = String(center[center.startIndex..<fIndex])
        let yStr = String(center[sIndex..<center.endIndex])
        guard let x = xStr.cgFloat, let y = yStr.cgFloat else {
            return nil
        }
        return (x, y)
    }
}
