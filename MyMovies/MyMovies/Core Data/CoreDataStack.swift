
import UIKit
import CoreData

// Manager for getting data
class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    // How we interact with our data store
    let mainContext: NSManagedObjectContext
    
    init() {
        
        // Create a container, give it the name of data model file
        container = NSPersistentContainer(name: "MyMovies")
        
        // Load the stores
        container.loadPersistentStores { (description, error) in
            if let e = error {
                fatalError("Couldn't load the data store: \(e)")
            }
        }
        
        mainContext = container.viewContext
        
    }
    
    func makeNewFetchedResultsController() -> NSFetchedResultsController<Movie> {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: mainContext,
                                             sectionNameKeyPath: nil, // "hasWatched"
                                             cacheName: nil)
        
        return frc
        
        
    }
    
    
}
