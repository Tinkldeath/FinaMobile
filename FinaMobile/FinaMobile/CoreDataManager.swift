//
//  CoreDataManager.swift
//  FinaMobile
//
//  Created by Dima on 18.09.23.
//

import Foundation
import CoreData


final class CoreDataManager {
    
    private static var _instnace = CoreDataManager()
    public static var shared = {
       return _instnace
    }()
    private init() {}
    
    // MARK: - Core Data stack
    private(set) lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "FinaMobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
