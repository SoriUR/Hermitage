//
//  Path.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

struct Path: Codable {
    let color: String
    let destDevice: String
    let length: Int
    let optimal: Bool
    let pathId: String
    let devices: [String]
}

struct ServerResponseJSON: Codable {
    let error: Bool
    let errorDetails: String?
    let result: Path?
}
