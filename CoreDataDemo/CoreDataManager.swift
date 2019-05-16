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
        
        let persistentContainer = NSPersistentContainer(name: "CompaniesModel")
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            
            if let error = error {
                fatalError("Loading Persistent Store failed \(error)")
            }
        }
        
        return persistentContainer
    }()
}
