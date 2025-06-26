//
//  AlcoholEntry.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 25.06.25.
//

import Foundation

class AlcoholEntry: Codable {
    let id: UUID
    let name: String
    let amountML: Int
    let date: Date
    
    init(name: String, amountML: Int, date: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.amountML = amountML
        self.date = date
    }
}
