//
//  NavigationModel.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

class StartNavigationModel: LightDecoder {

    private let buffer: Buffer<Location> = Buffer(capacity: 2)

    var delegate: LightDecoderDelegate?

    func decode(bytes: [UInt8]) {
        guard let str = decodeBytes(bytes), let location = decodeLocation(str) else {
            return
        }

        appendToBuffer(location: location)
    }

    private func appendToBuffer(location: Location) {
        buffer.push(location)
        guard buffer.isHomogeneous else {
            return
        }
        delegate?.didRecognizeLocation(location)
        buffer.flush()
    }
}
