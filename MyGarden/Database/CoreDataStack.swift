//
//  CoreDataStack.swift
//  MyGarden
//
//  Created by Olesya Tranina on 14/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyGarden")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("unable to load persistent store")
            }
        })
        return container
    }()
    
}
