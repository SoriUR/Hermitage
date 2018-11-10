//
//  Buffer.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

class Buffer<T: Equatable> {
    private var bufferItems: [T] = []
    private let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
    }

    var isHomogeneous: Bool {
        guard bufferItems.count == capacity, let firstElem = bufferItems.first else {
            return false
        }

        return !bufferItems.contains { $0 != firstElem }
    }

    func push(_ newElement: T) {
        print("added location: \(newElement)")
        bufferItems.append(newElement)
        if bufferItems.count > capacity, capacity > 0 {
             bufferItems.remove(at: 0)
        }
    }

    func flush() {
        bufferItems = []
    }
}

