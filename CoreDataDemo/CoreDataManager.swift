//
//  CoreDataManager.swift
//  CoreDataDemo
//
//  Created by Martin Mungai on 15/05/2019.
//  Copyright © 2019 GeniusAppz. All rights reserved.
//

import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CompaniesModel")
        container.loadPersistentStores { (storeDescription, error) in
            
            if let error = error {
                fatalError("Loading Persistent Store failed \(error)")
            }
        }
        
        return container
    }()
    
    func fetchCompanies() -> [Company] {
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try persistentContainer.viewContext.fetch(fetchRequest)
            return companies
        }
        catch let fetchError {
            print("Failed to fetch companies: \(fetchError)")
            return []
        }
    }
}
