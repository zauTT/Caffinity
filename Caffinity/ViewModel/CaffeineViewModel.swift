//
//  caffeineViewModel.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class CaffeineViewModel {
    
    private let entriesKey = "caffeineEntries"
    
    private(set) var entries: [CaffeineEntry] = []
    var onDataChange: (() -> Void)?
    
    private(set) var availableDrinks: [Drink] = []
    
    var drinksByCategory: [String: [Drink]] {
        Dictionary(grouping: availableDrinks, by: { $0.category })
    }
    
    var sortedCategories: [String] {
        drinksByCategory.keys.sorted()
    }
    
    let dailyLimitMG = 400
    
    var hasExceededLimit: Bool {
        totalCaffeineToday > dailyLimitMG
    }
    
    init() {
        loadAvailableDrinks()
        loadEntries()
    }
    
    var totalCaffeineToday: Int {
        let calendar = Calendar.current
        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
        return todayEntries.reduce(0) { $0 + $1.amountMG }
    }
    
    @discardableResult
    func addEntry(name: String, amountMG: Int, date: Date = Date()) -> Bool {
        let newEntry = CaffeineEntry(name: name, amountMG: amountMG, date: date)
        entries.append(newEntry)
        saveEntries()
        onDataChange?()
        return totalCaffeineToday > dailyLimitMG
    }
    
    func numberOfEntries() -> Int {
        return entries.count
    }
    
    func entry(at index: Int) -> CaffeineEntry? {
        guard index >= 0 && index < entries.count else { return nil }
        return entries[index]
    }
    
    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: entriesKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else { return }
        do {
            entries = try JSONDecoder().decode([CaffeineEntry].self, from: data)
        } catch {
            print("fialed to load entries: \(error)")
        }
    }
    
    func deleteEntry(at index: Int) {
        guard index >= 0 && index < entries.count else { return }
        entries.remove(at: index)
        saveEntries()
        onDataChange?()
    }
    
    private func loadAvailableDrinks() {
        if let url = Bundle.main.url(forResource: "caffeine_data", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                availableDrinks = try decoder.decode([Drink].self, from: data)
                print("Loaded drinks: \(availableDrinks.map { $0.name })")
            } catch {
                print("JSON decode error: \(error)")
            }
        } else {
            print("❌ caffeine_data.json not found in main bundle")
        }
    }
}
