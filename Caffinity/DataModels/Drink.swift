//
//  Drink.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 10.06.25.
//

import Foundation

struct Drink: Codable {
    let name: String
    let caffeineMG: Int
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case caffeineMG = "caffeineMg"  // map JSON "caffeineMg" to property "caffeineMG"
        case category
    }
}
