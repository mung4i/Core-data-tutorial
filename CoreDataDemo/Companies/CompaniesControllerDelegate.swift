//
//  CompaniesControllerDelegate.swift
//  CoreDataDemo
//
//  Created by Martin Mungai on 17/05/2019.
//  Copyright © 2019 GeniusAppz. All rights reserved.
//

import UIKit

extension CompaniesController: CreateCompanyControllerDelegate {
    
    func didEditCompany(company: Company) {
        
        let _companies = CoreDataManager.shared.fetchCompanies()
        self.companies = _companies
        
        let row = companies.index(of: company)!
        let reloadIndexPath = IndexPath(row: row, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .automatic)
    }
    
    func didSaveCompany() {
        let _companies = CoreDataManager.shared.fetchCompanies()
        self.companies = _companies
        
        reloadTableView()
    }
}
