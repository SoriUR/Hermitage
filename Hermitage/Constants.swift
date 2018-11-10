//
//  Constants.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

class Constants {
    enum URL {
        static let baseUrl = "http://137.74.114.219:44093"

        static let calculatePath = baseUrl + "/path/calc"
        static let clearPath = baseUrl + "/path/reset"
    }
}
