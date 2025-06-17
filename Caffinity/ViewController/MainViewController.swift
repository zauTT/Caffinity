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
        
        edgeSwipeGesture()
        
        setupLayout()
        setupBindings()
        
        tableView.register(CaffeineEntryCell.self, forCellReuseIdentifier: CaffeineEntryCell.identifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "History >", style: .plain, target: self, action: #selector(showHistory))
        
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
        totalLabel.text = "Total Caffeine Today: \(viewModel.totalCaffeineToday()) mg"
        tableView.reloadData()
    }
    
    private func edgeSwipeGesture() {
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipe(_:)))
        edgeSwipe.edges = [.right]
        view.addGestureRecognizer(edgeSwipe)
    }
    
    @objc private func handleEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            let historyVC = HistoryViewController()
            navigationController?.pushViewController(historyVC, animated: true)
        }
    }
    
    @objc private func showHistory() {
        let historyVC = HistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc private func addDrinkTapped() {
        let pickerVC = DrinkPickerViewController()
        pickerVC.modalPresentationStyle = .pageSheet
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        pickerVC.drinks = viewModel.availableDrinks
        
        pickerVC.onDrinkSelected = { [weak self] drink in
            guard let self = self else { return }
            let exceeded = self.viewModel.addEntry(name: drink.name, amountMG: drink.caffeineMG)
            
            self.dismiss(animated: true) {
                if exceeded {
                    let alert = UIAlertController(
                        title: "⚠️ Caffeine Limit Exceeded",
                        message: "You’ve consumed more than 400mg of caffeine today. Please be cautious!",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        pickerVC.modalPresentationStyle = .formSheet
        present(pickerVC, animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEntriesToday()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entry = viewModel.entryFromToday(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CaffeineEntryCell.identifier, for: indexPath) as! CaffeineEntryCell
        cell.configure(with: entry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteEntryFromToday(at: indexPath.row)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

