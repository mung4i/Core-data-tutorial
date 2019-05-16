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
    
    var delegate: CompanyControllerDelegate?
    
    private var companies = [Company]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        setupTableView()
        
        self.fetchCompanies()
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
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(company)
        
        do {
            try context.save()
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
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try context.fetch(fetchRequest)
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
    
    private func reloadTableView() {
        self.tableView.reloadData()
    }
    
    private func setupNavigationItems() {
        
        let add = UIImage(named: "add")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: add, style: .plain, target: self, action: #selector(handleAddCompany))
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

