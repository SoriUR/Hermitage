//
//  LightDecoder.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

protocol LightDecoder: class {
    func decode(bytes: [UInt8]) -> String?
}
