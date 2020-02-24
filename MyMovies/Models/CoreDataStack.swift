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
        return newContainer
    }()
    
    /// Creates Managed Object Context
    // Retrive with "CoreDataStack.shared.mainContext"
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    
    // MARK: - Initializers
    
    private init() {}
}
