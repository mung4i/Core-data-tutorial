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
    let Context = CoreDataManager.shared.persistentContainer.viewContext
    
    //
    // MARK: Properties
    //
    
    var delegate: CompanyControllerDelegate?
    
    private var companies = [Company]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        setupTableView()
        fetchCompanies()
    }
    
    //
    // MARK: TableView Delegate
    //
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteHandler)
        deleteAction.backgroundColor = .lightRed
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: editHandler)
        editAction.backgroundColor = .darkBlue
        
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightBlue
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return companies.count == 0 ? 150 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.text = "No companies available..."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }
    
    //
    // MARK: TableView DataSource
    //
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier, for: indexPath)
        let company = companies[indexPath.row]
        
        cell.backgroundColor = .tealColor
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.textLabel?.textColor = .white
        
        let name = company.name ?? "Default Company"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let date = dateFormatter.string(from: company.founded ?? Date())
        
        cell.textLabel?.text = "\(name) - Founded: \(date)"
        
        cell.imageView?.clipsToBounds = true
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = UIImage(named: "default_profile")
        
        if let imageData = company.imageData {
            cell.imageView?.image = UIImage(data: imageData)
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    //
    // MARK: Private Instance Methods
    //
    
    private func deleteHandler(action: UITableViewRowAction, indexPath: IndexPath) {
        
        let company = self.companies[indexPath.row]
        print("Attempting to delete company:" , company.name ?? "")
        
        self.companies.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        Context.delete(company)
        
        do {
            try Context.save()
        } catch let saveError {
            print("Failed to delete company.", company.name ?? "", saveError)
        }
    }
    
    private func editHandler(action: UITableViewRowAction, indexPath: IndexPath) {
        
        let editCompanyController = CreateCompanyController()
        editCompanyController.delegate = self
        editCompanyController.company = companies[indexPath.row]
        
        let navController = CustomNavigationController(rootViewController: editCompanyController)
        present(navController, animated: true)
    }
    
    private func fetchCompanies() {
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try Context.fetch(fetchRequest)
            self.companies = companies
        }
        catch let fetchError {
            fatalError("Failed to fetch companies: \(fetchError)" )
        }
    }
    
    @objc
    private func handleAddCompany() {
        print("Adding company...")
        
        let createCompanyController = CreateCompanyController()
        createCompanyController.delegate = self
        
        let navigationController = CustomNavigationController(rootViewController: createCompanyController)
        present(navigationController, animated: true)
    }
    
    @objc private func handleReset() {
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do {
            try Context.execute(batchDeleteRequest)
            
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
    
    private func reloadTableView() {
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier)
    }
}

extension CompaniesController: CompanyControllerDelegate {
    
    func didEditCompany(company: Company) {
        self.fetchCompanies()
        let row = companies.index(of: company)!
        let reloadIndexPath = IndexPath(row: row, section: 0)
        self.tableView.reloadRows(at: [reloadIndexPath], with: .automatic)
    }
    
    func didSaveCompany() {
        self.fetchCompanies()
        self.reloadTableView()
    }
}

