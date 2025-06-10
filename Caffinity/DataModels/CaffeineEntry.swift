//
//  CaffeineEntry.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class CaffeineEntry {
    var name: String
    var amoundMG: Int
    var date: Date
    
    init(name: String, amoundMG: Int, date: Date = Date()) {
        self.name = name
        self.amoundMG = amoundMG
        self.date = date
    }
}
