//
//  LightDecoder.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

protocol LightDecoder: class {
    func decode(bytes: [UInt8])

    var delegate: LightDecoderDelegate? { get set }
}

extension LightDecoder {
    /// Creates new Locatio instanse  from binary string
    ///
    /// - Parameter string: string containing just "1" and "0" with length of 12. Were first 3 digits are dedicated to zone, following 6 digits are dedicated to room and last 3 digits dedecated to device.
    /// - Returns: current location or nil if smth goes wrong
    func decodeLocation(_ string: String) -> Location? {
        guard string.count == 12 else {
            return nil
        }
        let zoneIndex = string.index(string.startIndex, offsetBy: 3)
        let roomIndex = string.index(string.startIndex, offsetBy: 9)
        guard let zone = String(string[..<zoneIndex]).toDecimal,
            let room = String(string[zoneIndex..<roomIndex]).toDecimal,
            let device = String(string[roomIndex..<string.endIndex]).toDecimal else {
                return nil
        }

        return Location(zone: zone, room: room, device: device)
    }

    func decodeBytes(_ bytes: [UInt8]) -> String? {
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

        return decodeBinaryString(resultBinary)
    }

    private func decodeBinaryString(_ string: String) -> String? {
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
        let oddCount = string.reduce(0) {
            return $0 + ($1 == "1" ? 1 : 0)
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

protocol LightDecoderDelegate: class {
    func didRecognizeLocation(_ location: Location)
}
