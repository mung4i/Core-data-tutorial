//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Martin Mungai on 15/05/2019.
//  Copyright © 2019 GeniusAppz. All rights reserved.
//

import UIKit
import CoreData

class CompaniesController: UITableViewController {
    
    //
    // MARK: Constants
    //
    
    let CellReuseIdentifier = "cellId"
    //
    // MARK: Properties
    //
    
    var delegate: CreateCompanyControllerDelegate?
    
    var companies = [Company]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupTableView()
        
        self.companies = CoreDataManager.shared.fetchCompanies()
    }
    
    //
    // MARK: Private Instance Methods
    //
    
    func deleteHandler(action: UITableViewRowAction, indexPath: IndexPath) {
        
        let company = self.companies[indexPath.row]
        print("Attempting to delete company:" , company.name ?? "")
        
        self.companies.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(company)
        
        do {
            try context.save()
        } catch let saveError {
            print("Failed to delete company.", company.name ?? "", saveError)
        }
    }
    
    func editHandler(action: UITableViewRowAction, indexPath: IndexPath) {
        
        let editCompanyController = CreateCompanyController()
        editCompanyController.delegate = self
        editCompanyController.company = companies[indexPath.row]
        
        let navController = CustomNavigationController(rootViewController: editCompanyController)
        present(navController, animated: true)
    }
    
    @objc
    func handleAddCompany() {
        print("Adding company...")
        
        let createCompanyController = CreateCompanyController()
        createCompanyController.delegate = self
        
        let navigationController = CustomNavigationController(rootViewController: createCompanyController)
        present(navigationController, animated: true)
    }
    
    @objc
    func handleReset() {
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try context.execute(batchDeleteRequest)
            
            var indexPathsToRemove = [IndexPath]()
            
            for (index, _) in companies.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)
        }
        
        catch let deleteError {
            fatalError("Failed to delete objects from Core Data: \(deleteError)")
        }
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    private func setupNavigationItems() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))
        
        let add = UIImage(named: "custom_button")?.withRenderingMode(.alwaysOriginal)
        
        let button = UIBarButtonItem(image: add, style: .plain, target: self, action: #selector(handleAddCompany))
        button.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        navigationItem.rightBarButtonItem = button
        
        navigationItem.title = "Companies"
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .darkBlue
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView()
        tableView.register(CompanyCell.self, forCellReuseIdentifier: CellReuseIdentifier)
    }
}

