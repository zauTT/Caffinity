//
//  MainViewController.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 10.06.25.
//

import UIKit

class MainViewController: UIViewController {
    
    private let viewModel = CaffeineViewModel()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Caffeine Today: 0 mg"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
//        tv.backgroundColor = UIColor(red: 0.0/255.0, green: 63.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "entryCell")
        return tv
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add Drink", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Caffinity ☕️"
        view.backgroundColor = .systemBackground
//        view.backgroundColor = UIColor(red: 0.0/255.0, green: 63.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        
        setupLayout()
        setupBindings()
        
        tableView.dataSource = self
        addButton.addTarget(self, action: #selector(addDrinkTapped), for: .touchUpInside)
        
    }
    
    private func setupLayout() {
        view.addSubview(totalLabel)
        view.addSubview(tableView)
        view.addSubview(addButton)
        
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onDataChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        updateUI()
    }
    
    private func updateUI() {
        totalLabel.text = "Total Caffeine Today: \(viewModel.totalCaffeineToday)mg"
        tableView.reloadData()
    }
    
    @objc private func addDrinkTapped() {
        print("Drinks passed to picker: \(viewModel.availableDrinks.map { $0.name })") // ✅ DEBUG LINE

        let pickerVC = DrinkPickerViewController()
        pickerVC.drinks = viewModel.availableDrinks
        pickerVC.onDrinkSelected = { [weak self] drink in
            self?.viewModel.addEntry(name: drink.name, amountMG: drink.caffeineMG)
        }
        pickerVC.modalPresentationStyle = .formSheet
        present(pickerVC, animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEntries()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = viewModel.entry(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        cell.textLabel?.text = "\(entry?.name ?? "") - \(entry?.amountMG ?? 0)mg at \(formatter.string(from: entry?.date ?? Date()))"
        return cell
    }
}

