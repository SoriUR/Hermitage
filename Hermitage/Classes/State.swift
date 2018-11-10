//
//  State.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

enum State: String {
    case zero = "0"
    case one = "1"

    func isDifferent(to state: State) -> Bool {
        return self != state
    }

    static var border: Float = Float(UInt8.max / 2)

    static func getState(dependsOn byte: UInt8) -> State {
        return Float(byte) > border ? .one : .zero
    }
}
