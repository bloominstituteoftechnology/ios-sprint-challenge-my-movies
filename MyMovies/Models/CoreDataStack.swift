import Foundation
import CoreData

class CoreDataStack {
    
    
    // MARK: - Properties
    
    /// Shared instance of CoreDataStack
    static let shared = CoreDataStack()
    
    /// Creates Persistent Store & Persistent Store Coordinator
    lazy var container: NSPersistentContainer = {
        let newContainer = NSPersistentContainer(name: "MyMovies")
        newContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        newContainer.viewContext.automaticallyMergesChangesFromParent = true
        return newContainer
    }()
    
    /// Creates Managed Object Context
    // Retrive with "CoreDataStack.shared.mainContext"
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    
    // MARK: - Initializers
    
    private init() {}
    
    
    // MARK: - Functions
    
    func save(context: NSManagedObjectContext) throws {
        var saveError: Error?
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        
        if let saveError = saveError { throw saveError }
    }
}
