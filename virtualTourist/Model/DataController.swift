//
//  DataController.swift
//  virtualTourist
//
//  Created by Kevin Veldkamp on 7/8/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import CoreData

class DataController{

    let persistentContainer:NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var backgroundContext: NSManagedObjectContext!

    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }


    func configureContexts(){
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
            
        }
    }
}
