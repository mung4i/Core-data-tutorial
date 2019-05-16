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
    
    private var companies = [Company]()
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        fetchCompanies()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        setupTableView()
    }
    
    //
    // MARK: TableView Delegate
    //
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
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
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
            let company = self.companies[indexPath.row]
            print("Editing company:.." , company.name ?? "")
        }
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
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = company.name
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
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
        
        self.tableView.reloadData()
    }
    
    //
    // MARK: Private Instance Methods
    //
    
    @objc
    private func handleAddCompany() {
        print("Adding company...")
        
        let createCompanyController = CreateCompanyController()
        let navigationController = CustomNavigationController(rootViewController: createCompanyController)
        present(navigationController, animated: true)
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

