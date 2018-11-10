//
//  NavigationModel.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

class NavigationModel: LightDecoder {

    private enum State: String {
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

    func decode(bytes: [UInt8]) -> String? {
        var resultBinary: String = ""
        State.border = Float(bytes.max()! - bytes.min()!) / 2

        let (zeroMinWidth, oneMinWidth) = decodeWidths(from: bytes)
        var lastState = State.getState(dependsOn: bytes[0])
        let function: (_ width: Int) -> Int = { width in
            let etalonWidth = lastState == .zero ? zeroMinWidth : oneMinWidth
            return width / etalonWidth
        }

        var currentWidth = 0
        for byteIndex in 1..<bytes.count {
            let currentByte = bytes[byteIndex]
            let currentState = State.getState(dependsOn: currentByte)
            currentWidth += 1

            guard currentState.isDifferent(to: lastState) else {
                continue
            }
            let etalonWidth = lastState == .zero ? zeroMinWidth : oneMinWidth
            guard currentWidth >= etalonWidth else { continue }

            let digitsNumber = function(currentWidth)
            for _ in 0..<digitsNumber {
                resultBinary.append(lastState.rawValue)
            }

            lastState = currentState
            currentWidth = 0
        }

        let digitsNumber = function(currentWidth+1)
        for _ in 0..<digitsNumber {
            resultBinary.append(lastState.rawValue)
        }

        return decodeBynaryString(resultBinary)
    }

    private func decodeBynaryString(_ string: String) -> String? {
        let indexes = string.indexes(of: "0110")
        guard !indexes.isEmpty else {
            return nil
        }
        for i in 0..<indexes.count - 1 {
            var str = ""
            let startIndex = indexes[i]
            let endIndex = indexes[i+1]

            let tempString = String(string[startIndex...endIndex])
            for (index, char) in tempString.enumerated() {
                if index < 5 { continue }
                if index % 2 == 0 { continue }
                if index > tempString.count - 3 { continue}
                str += String(char)
            }
            if stringIsValid(str) {
                return String(str.dropLast())
            }
        }

        return nil
    }

    private func stringIsValid(_ string: String) -> Bool {
        guard string.count == 13 else { return false }
        var oddCount = 0
        for (index, char) in string.enumerated() {
            if char == "1" {
                oddCount += 1
            }
        }
        guard oddCount % 2 == 0 else {
            return false
        }
        return true
    }

    private func decodeWidths(from bytes: [UInt8]) -> (zeroWidth: Int, oneWidth: Int) {
        var lastState = State.getState(dependsOn: bytes[0])
        var zeroWidth = Int.max
        var oneWidth = Int.max

        var currentWidth = 0
        for byteIndex in 1..<bytes.count {
            let currentByte = bytes[byteIndex]
            let currentState = State.getState(dependsOn: currentByte)
            currentWidth += 1

            guard currentState.isDifferent(to: lastState), currentWidth > 4 else {
                continue
            }

            switch lastState {
            case .zero:
                zeroWidth = min(zeroWidth, currentWidth)
            case .one:
                oneWidth = min(zeroWidth, currentWidth)
            }

            lastState = currentState
            currentWidth = 0
        }

        return (zeroWidth, oneWidth)
    }
}
