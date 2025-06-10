//
//  DrinkPickerViewController.swift
//  Caffinity
//
//  Created by Giorgi Zautashvili on 10.06.25.
//


import UIKit

class DrinkPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var drinks: [Drink] = []
    var onDrinkSelected: ((Drink) -> Void)?
        
        private let picker = UIPickerView()
        private let selectButton = UIButton(type: .system)
        private let cancelButton = UIButton(type: .system)
        
        private var selectedIndex = 0

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            setupLayout()
            
            picker.dataSource = self
            picker.delegate = self
            
            picker.reloadAllComponents()
        }
        
        private func setupLayout() {
            view.addSubview(picker)
            view.addSubview(selectButton)
            view.addSubview(cancelButton)
            
            picker.translatesAutoresizingMaskIntoConstraints = false
            selectButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            
            selectButton.setTitle("Select", for: .normal)
            cancelButton.setTitle("Cancel", for: .normal)
            
            selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
            cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                picker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                selectButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 20),
                selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                cancelButton.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 10),
                cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        }
        
        @objc private func selectTapped() {
            let selectedDrink = drinks[selectedIndex]
            onDrinkSelected?(selectedDrink)
            dismiss(animated: true)
        }
        
        @objc private func cancelTapped() {
            dismiss(animated: true)
        }
        
        // MARK: - UIPickerView
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return drinks.count
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            let drink = drinks[row]
            return "\(drink.name) (\(drink.caffeineMG)mg)"
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedIndex = row
        }
    }
