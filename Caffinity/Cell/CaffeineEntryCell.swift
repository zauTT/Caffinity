//
//  CaffeineEntryCell.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 11.06.25.
//

import UIKit

class CaffeineEntryCell: UITableViewCell {
    
    static let identifier = "CaffeineEntryCell"
    
    private let nameLabel = UILabel()
    private let caffeineLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        caffeineLabel.font = UIFont.systemFont(ofSize: 14)
        caffeineLabel.textColor = .systemGray
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .systemGray2
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, caffeineLabel, timeLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with entry: CaffeineEntry) {
        nameLabel.text = entry.name
        caffeineLabel.text = "\(entry.amountMG) mg"
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: entry.date)
    }
    
}
