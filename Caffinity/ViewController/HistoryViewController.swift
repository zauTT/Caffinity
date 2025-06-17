//
//  HistoryViewController.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 15.06.25.
//


import UIKit

class HistoryViewController: UIViewController {
    
    private let viewModel = CaffeineViewModel()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    private let averageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private var last7DaysData: [(date: Date, entries: [CaffeineEntry])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupAverageLabel()
        loadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
        
                tableView.delegate = self
                tableView.dataSource = self
        
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
    }
    
    private func setupAverageLabel() {
        view.addSubview(averageLabel)
        averageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            averageLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            averageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            averageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            averageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    private func loadData() {
        last7DaysData = viewModel.last7DaysEntries()
        averageLabel.text = "Average daily caffeine intake (last 7 days): \(viewModel.dailyAverageForLast7Days()) mg"
        tableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return last7DaysData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let calendar = Calendar.current
        let date = last7DaysData[section].date
        let today = Date()
        
        let daysAgo = calendar.dateComponents([.day], from: date, to: today).day ?? 0
        
        switch daysAgo {
        case 0: return "Today"
        case 1: return "Yesterday"
        default: return "\(daysAgo) days ago"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (_, entries) = last7DaysData[indexPath.section]
        let totalCaffeine = entries.reduce(0) { $0 + $1.amountMG }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = "You took \(totalCaffeine) mg caffeine"
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (date, entries) = last7DaysData[indexPath.section]
        tableView.deselectRow(at: indexPath, animated: true)
        
        if entries.isEmpty {
            let alert = UIAlertController(title: "No drinks", message: "You did not consume any caffeine this day.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let dateString = formatter.string(from: date)
        var message = ""
        for entry in entries {
            message += "• \(entry.name): \(entry.amountMG) mg\n"
        }
        
        let alert = UIAlertController(title: "Drinks on \(dateString)", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
}
