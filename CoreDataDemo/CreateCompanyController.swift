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
    
    func didEditCompany(company: Company)
    func didSaveCompany()
}

class CreateCompanyController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: CreateCompanyControllerDelegate?
    
    var company: Company? {
        
        didSet {
            
            self.nameTextField.text = company?.name
            
            if let imageData = company?.imageData {
                imageView.image = UIImage(data: imageData)
            }
            
            guard let founded = company?.founded
                else { return }
            datePicker.date = founded
        }
    }
    
    //
    // MARK: Constants
    //
    
    let datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    let backgroundView: UIView = {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightBlue
        
        // enable Autolayout
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        return backgroundView
    }()
    
    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage(named: "default_profile"))
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        return imageView
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = editedImage
        }
        
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = originalImage
        }
        
        setupCircularImageStyle()
        
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = company == nil ? "Create Company" : "Edit Company"
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
        if company == nil {
            createCompany()
        } else {
            saveCompanyChanges()
        }
    }
    
    @objc
    private func handleSelectPhoto() {
        print("Attempting to select Photo...")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    private func createCompany() {
        
        guard let name = self.nameTextField.text else { return }
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let company = NSEntityDescription.insertNewObject(forEntityName: "Company", into: context)
        company.setValue(name, forKey: "name")
        company.setValue(datePicker.date, forKey: "founded")
        
        if let image = imageView.image {
            
            let imageData = image.jpegData(compressionQuality: 0.8)
            company.setValue(imageData, forKey: "imageData")
        }
        
        do {
            try context.save()
            dismiss(animated: true, completion: {
                self.delegate?.didSaveCompany()
            })
            
        } catch let saveError {
            fatalError("Failed to save company: \(saveError)")
        }
    }
    
    private func saveCompanyChanges() {
        
        company?.name = nameTextField.text
        company?.founded = datePicker.date
        company?.imageData = imageView.image?.jpegData(compressionQuality: 0.8)
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.save()
            dismiss(animated: true, completion: {
                self.delegate?.didEditCompany(company: self.company!)
            })
        } catch let saveError {
            fatalError("Failed to save company changes: \(saveError)")
        }
    }
    
    private func setupCircularImageStyle() {
        
        imageView.layoutIfNeeded()
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
    }
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        navigationItem.title = "Create Company"
    }
    
    private func setupUI() {
        
        view.backgroundColor = .darkBlue
        // BackgroundView
        
        view.addSubview(backgroundView)
        
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        // ImageView
        
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        setupCircularImageStyle()
        
        // Label
        
        view.addSubview(nameLabel)
        
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // UITextField
        
        view.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
        // Datepicker
        
        view.addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
    }
}
