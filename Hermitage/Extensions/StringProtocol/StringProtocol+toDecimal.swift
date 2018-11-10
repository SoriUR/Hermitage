//
//  StringProtocol.swift
//  Hermitage
//
//  Created by Юрий Сорокин on 10/11/2018.
//  Copyright © 2018 Iurii Sorokin. All rights reserved.
//

import Foundation

extension String {
    var toDecimal: Int? {
        return Int(self, radix: 2)
    }
}
