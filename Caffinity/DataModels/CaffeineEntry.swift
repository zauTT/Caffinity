//
//  CaffeineEntry.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class CaffeineEntry: Codable {
    var name: String
    var amountMG: Int
    var date: Date
    
    init(name: String, amountMG: Int, date: Date = Date()) {
        self.name = name
        self.amountMG = amountMG
        self.date = date
    }
}
