//
//  Double+Helper.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/31/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

extension Double {
    var date: Date {
        return Date(timeIntervalSince1970: self / 1000.0)
    }
}
