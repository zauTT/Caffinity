//
//  AlcoholViewModel.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 25.06.25.
//


import Foundation

class AlcoholViewModel {
    private(set) var allEntries: [AlcoholEntry] = []
    private(set) var availableDrinks: [AlcoholDrink] = []
    
    var onDataChange: (() -> Void)?
    private let dailyLimitML = 550
    private let entriesKey = "alcoholEntries"
    
    init() {
        loadAvailableDrinks()
        loadEntries()
    }
    
    @discardableResult
    func addEntry(name: String, amountML: Int, date: Date = Date()) -> Bool {
        let entry = AlcoholEntry(name: name, amountML: amountML, date: date)
        allEntries.append(entry)
        saveEntries()
        onDataChange?()
        return totalAlcohol(on: date) > dailyLimitML
    }
    
    func entries(for date: Date) -> [AlcoholEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func entriesForToday() -> [AlcoholEntry] {
        return entries(for: Date())
    }

    func numberOfEntriesToday() -> Int {
        return entriesForToday().count
    }
    
    func entryFromToday(at index: Int) -> AlcoholEntry? {
        let todayEntries = entriesForToday()
        return index < todayEntries.count ? todayEntries[index] : nil
    }
    
    func totalAlcohol(on date: Date) -> Int {
        return entries(for: date).reduce(0) { $0 + $1.amountML }
    }
    
    func totalAlcoholToday() -> Int {
        return totalAlcohol(on: Date())
    }
    
    func last7DaysEntries() -> [(date: Date, entries: [AlcoholEntry])] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            return (date: date, entries: entries(for: date))
        } .reversed()
    }
    
    func dailyAverageFor7Days() -> Int {
        let dailyTotals = last7DaysEntries().map { $0.entries.reduce(0) { $0 + $1.amountML } }
        return dailyTotals.reduce(0, +) / 7
    }
    
    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(allEntries)
            UserDefaults.standard.set(data, forKey: entriesKey)
        } catch {
            print("❌ Failed to save alcohol entries: \(error)")
        }
    }
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else { return }
        do {
            allEntries = try JSONDecoder().decode([AlcoholEntry].self, from: data)
        } catch {
            print("❌ Failed to load alcohol entries: \(error)")
        }
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
    
    // MARK: - Drinks List
    
    struct AlcoholDrink: Codable {
        let name: String
        let amountML: Int
        let category: String
    }
    
    var drinksByCategory: [String: [AlcoholDrink]] {
        Dictionary(grouping: availableDrinks, by: { $0.category })
    }
    
    var sortedCategories: [String] {
        drinksByCategory.keys.sorted()
    }
    
    private func loadAvailableDrinks() {
        if let url = Bundle.main.url(forResource: "alcohol_data", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let alcoholDrinks = try JSONDecoder().decode([AlcoholPickerDrink].self, from: data)
                self.availableDrinks = alcoholDrinks.map {
                    AlcoholDrink(name: $0.name, amountML: $0.amount, category: $0.category)
                }
                print("✅ Loaded alcohol drinks: \(availableDrinks.map { $0.name })")
            } catch {
                print("❌ Failed to load alcohol JSON: \(error)")
            }
        } else {
            print("❌ alcohol_data.json not found")
        }
    }
    
}
