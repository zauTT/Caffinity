//
//  caffeineViewModel.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class caffeineViewModel {
    private(set) var entries: [CaffeineEntry] = []
    var onDataChange: (() -> Void)?
    
    private(set) var availableDrinks: [Drink] = []
    
    init() {
        loadAvailableDrinks()
    }
    
    var totalCaffeineToday: Int {
        let calendar = Calendar.current
        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
        return todayEntries.reduce(0) { $0 + $1.amoundMG }
    }
    
    func addEntry(name: String, amoundMG: Int, date: Date = Date()) {
        let newEntrie = CaffeineEntry(name: name, amoundMG: amoundMG, date: date)
        entries.append(newEntrie)
        onDataChange?()
    }
    
    func numberOfEntries() -> Int {
        return entries.count
    }
    
    func entry(at index: Int) -> CaffeineEntry? {
        guard index >= 0 && index < entries.count else { return nil }
        return entries[index]
    }
    
    private func loadAvailableDrinks() {
        if let url = Bundle.main.url(forResource: "caffeine_data", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                availableDrinks = try decoder.decode([Drink].self, from: data)
            } catch {
                print("Error Decoding JSON: \(error)")
                availableDrinks = []
            }
        } else {
            print("could not find caffeine_data.json")
            availableDrinks = []
        }
    }
    
    struct Drink: Codable {
        let name: String
        let caffeineMG: Int
    }
    
}
