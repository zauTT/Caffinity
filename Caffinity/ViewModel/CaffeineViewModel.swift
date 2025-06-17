//
//  caffeineViewModel.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 09.06.25.
//

import Foundation

class CaffeineViewModel {
    
    private(set) var allEntries: [CaffeineEntry] = []
    
    let dailyLimitMG = 400
    
    var onDataChange: (() -> Void)?
    
    private(set) var availableDrinks: [Drink] = []
    
    var drinksByCategory: [String: [Drink]] {
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
                availableDrinks = try JSONDecoder().decode([Drink].self, from: data)
                print("✅ Loaded drinks: \(availableDrinks.map { $0.name })")
            } catch {
                print("❌ JSON decode error: \(error)")
            }
        } else {
            print("❌ caffeine_data.json not found in main bundle")
        }
    }
}


//
//class CaffeineViewModel {
//        
//    private(set) var allEntries: [CaffeineEntry] = []
//    
//    let dailyLimitMG = 400
//    
//    private(set) var entries: [CaffeineEntry] = []
//    
//    var onDataChange: (() -> Void)?
//    
//    private(set) var availableDrinks: [Drink] = []
//    
//    var drinksByCategory: [String: [Drink]] {
//        Dictionary(grouping: availableDrinks, by: { $0.category })
//    }
//    
//    var sortedCategories: [String] {
//        drinksByCategory.keys.sorted()
//    }
//    
//    var hasExceededLimit: Bool {
//        totalCaffeineToday > dailyLimitMG
//    }
//    
//    init() {
//        loadAvailableDrinks()
//        loadEntries()
//    }
//    
//    var totalCaffeineToday: Int {
//        let calendar = Calendar.current
//        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
//        return todayEntries.reduce(0) { $0 + $1.amountMG }
//    }
//    
//    @discardableResult
//    func addEntry(name: String, amountMG: Int, date: Date = Date()) -> Bool {
//        let newEntry = CaffeineEntry(name: name, amountMG: amountMG, date: date)
//        entries.append(newEntry)
//        saveEntries()
//        onDataChange?()
//        return totalCaffeineToday > dailyLimitMG
//    }
//    
//    func numberOfEntries() -> Int {
//        return entries.count
//    }
//    
//    func entry(at index: Int) -> CaffeineEntry? {
//        guard index >= 0 && index < entries.count else { return nil }
//        return entries[index]
//    }
//    
//    private func saveEntries() {
//        do {
//            let data = try JSONEncoder().encode(entries)
//            UserDefaults.standard.set(data, forKey: entriesKey)
//        } catch {
//            print("Failed to save entries: \(error)")
//        }
//    }
//    
//    private func loadEntries() {
//        guard let data = UserDefaults.standard.data(forKey: entriesKey) else { return }
//        do {
//            entries = try JSONDecoder().decode([CaffeineEntry].self, from: data)
//        } catch {
//            print("fialed to load entries: \(error)")
//        }
//    }
//    
//    func deleteEntry(at index: Int) {
//        guard index >= 0 && index < entries.count else { return }
//        entries.remove(at: index)
//        saveEntries()
//        onDataChange?()
//    }
//    
//    private func loadAvailableDrinks() {
//        if let url = Bundle.main.url(forResource: "caffeine_data", withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: url)
//                let decoder = JSONDecoder()
//                availableDrinks = try decoder.decode([Drink].self, from: data)
//                print("Loaded drinks: \(availableDrinks.map { $0.name })")
//            } catch {
//                print("JSON decode error: \(error)")
//            }
//        } else {
//            print("❌ caffeine_data.json not found in main bundle")
//        }
//    }
//    
//    /// MARK: Public API
//
//    func entriesForToday() -> [CaffeineEntry] {
//        return entries(for: Date())
//    }
//    
//    func entries(for: Date) -> [CaffeineEntry] {
//        let calendar = Calendar.current
//        return allEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
//    }
//    
//    func totalCaffeineForToday() -> Int {
//        return totalCaffeine(on: Date())
//    }
//    
//    func totalCaffeine(on date: Date) -> Int {
//        return entries(for: date).reduce(0) { $0 + $1.amountMG }
//    }
//    
//    func numberOfEntriesToday() -> Int {
//        return entriesForToday().count
//    }
//    
//    func entry(at index: Int) -> CaffeineEntry? {
//        let todayEntries = entriesForToday()
//        return index < todayEntries.count ? todayEntries[index] : nil
//    }
//    
//    /// MARK: Presistence
//    
//    private let entriesKey = "caffeineEntries"
//
//    
//    
//}
