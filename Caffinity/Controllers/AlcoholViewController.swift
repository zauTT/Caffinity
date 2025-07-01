//
//  AlcoholViewController.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 25.06.25.
//


import UIKit

class AlcoholViewController: UIViewController {
    
    private let viewModel = AlcoholViewModel()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
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
        title = "Alcohol 🍷"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "History ❯", style: .plain, target: self, action: #selector(showHistory))
        
        edgeSwipeGesture()
        
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
        totalLabel.text = "Total Alcohol Today: \(viewModel.totalAlcoholToday()) ml"
        tableView.reloadData()
    }
    
    private func edgeSwipeGesture() {
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipe(_:)))
        edgeSwipe.edges = [.right]
        view.addGestureRecognizer(edgeSwipe)
    }
    
    @objc private func handleEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            let historyVC = AlcoholHistoryViewController()
            navigationController?.pushViewController(historyVC, animated: true)
        }
    }
    
    @objc private func showHistory() {
        let historyVC = AlcoholHistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc private func addDrinkTapped() {
        let pickerVC = DrinkPickerViewController()
        pickerVC.modalPresentationStyle = .formSheet
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        
        pickerVC.drinks = viewModel.availableDrinks.map {
            PickerDrink(name: $0.name, amount: $0.amountML, category: $0.category)
        }
        
        pickerVC.onDrinkSelected = { [weak self] selected in
            guard let self = self else { return }
            let exceeded = self.viewModel.addEntry(name: selected.name, amountML: selected.amount)

            self.dismiss(animated: true) {
                if exceeded {
                    let alert = UIAlertController(
                        title: "⚠️ Alcohol Limit Exceeded",
                        message: "You've exceeded your daily alcohol intake. Please be cautious.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        
        present(pickerVC, animated: true)
    }
}

extension AlcoholViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEntriesToday()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entry = viewModel.entryFromToday(at: indexPath.row) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        cell.textLabel?.text = "\(entry.name) - \(entry.amountML) ml"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteEntryFromToday(at: indexPath.row)
        }
    }
}
