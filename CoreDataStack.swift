//
//  CoreDataStack.swift
//
//  Created by Aleksandr Sisiov on 2/8/19.
//

import CoreData

protocol CoreDataStack {
  var managedObjectContext: NSManagedObjectContext { set get }
  
  func createObject<T:NSManagedObject>(entityName:String) -> T
  func fetch<T>(entityName:String, filter: NSPredicate?, sort: NSSortDescriptor?) -> [T]
  func entity<T>(entityName:String, predicate:NSPredicate) -> T?
  
  func batchDelete(entityName:String)
  
  func saveContext()
  func removeEntity(_ entity:String)
}

extension CoreDataStack {
  func createObject<T:NSManagedObject>(entityName:String) -> T {
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
    return NSManagedObject(entity: entity!, insertInto: managedObjectContext) as! T
  }
  
  func fetch<T>(entityName:String, filter: NSPredicate?, sort: NSSortDescriptor?) -> [T] {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    fetch.predicate = filter
    
    if let sortDescription = sort {
      fetch.sortDescriptors = [sortDescription]
    }
    
    var result = [T]()
    
    do{
      result = try managedObjectContext.fetch(fetch) as! [T]
    } catch(let error) {
      print("Exception: \(error)")
    }
    
    return result
  }
  
  func entity<T>(entityName:String, predicate:NSPredicate) -> T? {
    return fetch(entityName: entityName, filter: predicate, sort: nil).first
  }
  
  func batchDelete(entityName: String) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
    deleteRequest.resultType = .resultTypeObjectIDs
    
    do {
      // Executes batch
      let result = try managedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
      
      // Retrieves the IDs deleted
      guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
      
      // Updates the main context
      let changes = [NSDeletedObjectsKey: objectIDs]
      NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedObjectContext])
    } catch {
      fatalError("Failed to execute request: \(error)")
    }
  }
  
  func saveContext() {
    
    managedObjectContext.performAndWait {
      if !self.managedObjectContext.hasChanges { return }
      
      do {
        try self.managedObjectContext.save()
      } catch {
        fatalError("Failure to save context: \(error)")
      }
    }
  }
  
  func removeEntity(_ entity: String) {
    batchDelete(entityName: entity)
  }
}
