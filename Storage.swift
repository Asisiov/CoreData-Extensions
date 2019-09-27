import CoreData

class Storage {
    static let shared = Storage()
    private init() {}
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: .itsMoti)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        })
        return container
    }()
}

extension Storage {
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
}

extension Storage {
    
    func insert<T: NSManagedObject>(_ entity: T.Type) -> T {
        let entityName = entity.entityName
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! T
    }
    
    func update<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate) -> T? {
        return fetch(entity, predicate: predicate)?.first
    }
    
    func fetch<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate) -> [T]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.entityName)
        fetchRequest.predicate = predicate
        do {
            return try context.fetch(fetchRequest) as? [T]
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func all<T: NSManagedObject>(_ entity: T.Type) -> [T]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.entityName)
        do {
            return try context.fetch(fetchRequest) as? [T]
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func clear<T: NSManagedObject>(_ entity: T.Type) {
        let fetchRequest = NSFetchRequest<T>(entityName: entity.entityName)
        do {
            _ = try context.fetch(fetchRequest).map { delete($0) }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
	
}