import Foundation
import CoreData

extension Movie {
    
    // MARK: - Initializers
    
    /// Creates Tasks with same Managed Object Context "moc"
    @discardableResult
    convenience init(hasWatched: Bool,
                     identifier: UUID? = UUID(),
                     title: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.hasWatched = hasWatched
        self.identifier = identifier
        self.title = title
    }
}
