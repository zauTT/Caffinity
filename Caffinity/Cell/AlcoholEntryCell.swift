//
//  AlcoholEntryCell.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 25.06.25.
//


import UIKit

class AlcoholEntryCell: UITableViewCell {
    static let identifier = "AlcoholEntryCell"
    
    func configure(with entry: AlcoholEntry) {
        textLabel?.text = "\(entry.name) - \(entry.amountML) ml"
        detailTextLabel?.text = DateFormatter.localizedString(from: entry.date, dateStyle: .short, timeStyle: .short)
    }
}