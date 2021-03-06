//
//  Date+Helper.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation

extension Date {
    var milisecondTimeIntervalSince1970: Double {
        return self.timeIntervalSince1970 * 1000
    }
}
