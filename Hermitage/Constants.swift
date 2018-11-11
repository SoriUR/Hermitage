//
//  Constants.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

class Constants {

    static let roomsInfo: [RoomInfo] = {
        let fileManager = FileManager.default
        let path = Bundle.main.path(forResource: "RoomsPixels", ofType: "json")!
        fileManager.fileExists(atPath: path)
        let data = try! NSData(contentsOfFile: path) as Data

        return try! JSONDecoder().decode([RoomInfo].self, from: data)
    }()

    enum URL {
        static let baseUrl = "http://95.213.28.151:44093"

        static let calculatePath = baseUrl + "/path/calc"
        static let clearPath = baseUrl + "/path/reset"
    }
}
