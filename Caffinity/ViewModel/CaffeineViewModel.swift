//
//  caffeineViewModel.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class CaffeineViewModel {
    
    private(set) var allEntries: [CaffeineEntry] = []
    private(set) var availableDrinks: [PickerDrink] = []
    
    let dailyLimitMG = 400
    
    var onDataChange: (() -> Void)?
    
    var drinksByCategory: [String: [PickerDrink]] {
        Dictionary(grouping: availableDrinks, by: { $0.category })
    }
    
    var sortedCategories: [String] {
        drinksByCategory.keys.sorted()
    }
    
    var hasExceededLimit: Bool {
        totalCaffeine(on: Date()) > dailyLimitMG
    }

    private let entriesKey = "caffeineEntries"
    
    init() {
        loadAvailableDrinks()
        loadEntries()
    }
    
    // MARK: - Entry Management
    
    @discardableResult
    func addEntry(name: String, amountMG: Int, date: Date = Date()) -> Bool {
        let entry = CaffeineEntry(name: name, amountMG: amountMG, date: date)
        allEntries.append(entry)
        saveEntries()
        onDataChange?()
        return totalCaffeine(on: date) > dailyLimitMG
    }
    
    func deleteEntryFromToday(at index: Int) {
        let today = Date()
        let todayEntries = entries(for: today)
        guard index < todayEntries.count else { return }
        let entryToDelete = todayEntries[index]
        
        if let actualIndex = allEntries.firstIndex(where: { $0.id == entryToDelete.id }) {
            allEntries.remove(at: actualIndex)
            saveEntries()
            onDataChange?()
        }
    }

    // MARK: - Public API

    func entries(for date: Date) -> [CaffeineEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func entriesForToday() -> [CaffeineEntry] {
        return entries(for: Date())
    }

    func numberOfEntriesToday() -> Int {
        return entriesForToday().count
    }

    func entryFromToday(at index: Int) -> CaffeineEntry? {
        let todayEntries = entriesForToday()
        return index < todayEntries.count ? todayEntries[index] : nil
    }

    func totalCaffeine(on date: Date) -> Int {
        return entries(for: date).reduce(0) { $0 + $1.amountMG }
    }

    func totalCaffeineToday() -> Int {
        return totalCaffeine(on: Date())
    }

    // MARK: - History API

    func last7DaysEntries() -> [(date: Date, entries: [CaffeineEntry])] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            return (date, entries(for: date))
        }.reversed()
    }

    func dailyAverageForLast7Days() -> Int {
        let dailyTotals = last7DaysEntries().map { $0.entries.reduce(0) { $0 + $1.amountMG } }
        return dailyTotals.reduce(0, +) / 7
    }

    // MARK: - Persistence

    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(allEntries)
            UserDefaults.standard.set(data, forKey: entriesKey)
        } catch {
            print("❌ Failed to save entries: \(error)")
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else { return }
        do {
            allEntries = try JSONDecoder().decode([CaffeineEntry].self, from: data)
        } catch {
            print("❌ Failed to load entries: \(error)")
        }
    }

    // MARK: - Drink List

    private func loadAvailableDrinks() {
        if let url = Bundle.main.url(forResource: "caffeine_data", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                availableDrinks = try JSONDecoder().decode([PickerDrink].self, from: data)
                print("✅ Loaded drinks: \(availableDrinks.map { $0.name })")
            } catch {
                print("❌ JSON decode error: \(error)")
            }
        } else {
            print("❌ caffeine_data.json not found in main bundle")
        }
    }
}
