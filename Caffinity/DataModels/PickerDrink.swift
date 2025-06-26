//
//  Drink.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 10.06.25.
//

import Foundation

struct PickerDrink: Codable {
    let name: String
    let amount: Int
    let category: String

    enum CodingKeys: String, CodingKey {
        case name
        case amount = "caffeineMg"
        case category
    }
}

struct AlcoholPickerDrink: Codable {
    let name: String
    let amount: Int
    let category: String

    enum CodingKeys: String, CodingKey {
        case name
        case amount = "amountML"
        case category
    }
}
