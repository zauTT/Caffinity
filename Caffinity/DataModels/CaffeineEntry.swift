//
//  CaffeineEntry.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class CaffeineEntry: Codable {
    let id: UUID
    var name: String
    var amountMG: Int
    var date: Date
    
    init(id: UUID = UUID(), name: String, amountMG: Int, date: Date = Date()) {
        self.id = id
        self.name = name
        self.amountMG = amountMG
        self.date = date
    }
}
