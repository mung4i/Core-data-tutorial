//
//  CreateCompanyController.swift
//  CoreDataDemo
//
//  Created by Martin Mungai on 15/05/2019.
//  Copyright © 2019 GeniusAppz. All rights reserved.
//

import UIKit
import CoreData

protocol CreateCompanyControllerDelegate {
    
    func didSaveCompany()
}

class CreateCompanyController: UIViewController {
    
    //
    // MARK: Constants
    //
    
    let lightBlueBackgroundView: UIView = {
        
        let lightBlueBackgroundView = UIView()
        lightBlueBackgroundView.backgroundColor = .lightBlue
        
        // enable Autolayout
        lightBlueBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        return lightBlueBackgroundView
    }()
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        view.backgroundColor = .darkBlue
        
        setupUI()
    }
    
    //
    // MARK: Private Instance Methods
    //
    
    @objc
    private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc
    private func handleSave() {
        print("Trying to save button...")
        
        dismiss(animated: true) {
            
            guard let name = self.nameTextField.text else { return }
            
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            let company = NSEntityDescription.insertNewObject(forEntityName: "Company", into: context)
            company.setValue(name, forKey: "name")
            
            do {
                try context.save()
            } catch let saveError {
                fatalError("Failed to save company: \(saveError)")
            }
        }
    }
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        navigationItem.title = "Create Company"
    }
    
    private func setupUI() {
        // BackgroundView
        
        view.addSubview(lightBlueBackgroundView)
        
        lightBlueBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lightBlueBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lightBlueBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lightBlueBackgroundView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Label
        
        view.addSubview(nameLabel)
    
        nameLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // UITextField
        
        view.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
    }
}
