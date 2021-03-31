//
//  GenericCoreDataManager.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 20/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

import Foundation
import CoreData

public class GenericCoreDataManager: NSObject {
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let currentBundle = modelBundle
        let modelURL = currentBundle.url(forResource: self.managedObjectModelName, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private let managedObjectModelName: String
    private let modelBundle: Bundle
    public init(managedObjectModelName : String, modelBundle: Bundle) {
        self.managedObjectModelName = managedObjectModelName
        self.modelBundle = modelBundle
    }
    
    
    fileprivate var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return urls.first!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        
        let persistentStoreURL = self.applicationDocumentsDirectory.appendingPathComponent(pathComponent)
        
        do {
            let options = [ NSInferMappingModelAutomaticallyOption : true,
                            NSMigratePersistentStoresAutomaticallyOption : true]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch let error {
            let logMessage = "\(#line) -> \(#function) \(error.localizedDescription)"
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    
    /*managed object context for UI updates */
    public lazy var mainQueueContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        moc.name = "Main Queue Context (UI Context)"
        return moc
    }()
    
    /*worker managed object context updates/creates managed objeccts in background and push changes to main queue context*/
    public lazy var privateQueueContext: NSManagedObjectContext  = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.mainQueueContext
        moc.name = "Primary Private Queue Context"
        return moc
    }()
    
    
//    static let sharedInstance = CoreDataManager()
//    private override init() {
//        super.init()
//    }
    
    public func pushChangesToUIContext() {
        // sequentialize the push
        privateQueueContext.perform {
            var error: Error?
            do {
                try self.privateQueueContext.save()
                
            } catch let saveError {
                error = saveError
                print("Please debug local this --> \(#file)--> \(#function) -> \(error!.localizedDescription)")
            }
        }
    }
    
    public func pushChangesToUIContext(completion :@escaping () -> Void) {
        // sequentialize the push
        privateQueueContext.perform {
            var error: Error?
            do {
                try self.privateQueueContext.save()
                
            } catch let saveError {
                error = saveError
                print("Please debug local this --> \(#file)--> \(#function) -> \(error!.localizedDescription)")
            }
            completion()
        }
    }
    
    public func saveChangesToStore() {
        var error: Error?
        self.mainQueueContext.performAndWait () {
            do {
                try self.mainQueueContext.save()
            } catch let saveError {
                error = saveError
                print("SAVE ERROR:----Please debug this --> \(#file)--> \(#function) -> \(error!.localizedDescription)")
            }
        }
    }
    
    public func insertManagedObject<T : NSManagedObject>(type : T.Type) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(type).components(separatedBy: ".").last!, into: self.privateQueueContext) as! T
    }
    
    public func fetchManagedObject<T : NSManagedObject>(type : T.Type, fetchRequest : NSFetchRequest<T>, context : NSManagedObjectContext) -> (fetchedObjects : [T]?, error: Error?) {
        do{
           let fetchedObjects =  try context.fetch(fetchRequest)
            return (fetchedObjects , nil)
        }catch let error{
            return (nil , error)
        }
    }
    
    public func deleteManagedObject<T : NSManagedObject>(managedObject : T, context : NSManagedObjectContext) {
        context.delete(managedObject)
    }
    
    public func deleteAllObjetcs<T : NSManagedObject>(type: T.Type, completion: (() -> Void)?) {
        deleteAllObjetcs(type: type, predicate: nil, completion: completion)
    }
    
    public func deleteAllObjetcs<T : NSManagedObject>(type: T.Type, predicate: NSPredicate?, completion: (() -> Void)?){
        privateQueueContext.perform {
            let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(type).components(separatedBy: ".").last!)
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let fetchedObjects =  try  self.privateQueueContext.fetch(fetchRequest)
                for anObject in fetchedObjects{
                   self.privateQueueContext.delete(anObject)
                }
                self.pushChangesToUIContext {
                    completion?()
                }
            } catch let _ {
                print("[DEBUG]: Unable to clear the records")
                completion?()
            }
        }
    }
    
    public func deleteAll(){
    }
    
}
