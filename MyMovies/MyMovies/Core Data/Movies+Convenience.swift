import Foundation
import CoreData

extension Movie {
    
    convenience init(identifier: UUID? = UUID(),
                     title: String,
                     hasWatched: Bool?,
                     managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: managedObjectContext)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched!
        
    }
    
    convenience init(representation: MovieRepresentation, managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(identifier: representation.identifier,
                  title: representation.title,
                  hasWatched: representation.hasWatched,
                  managedObjectContext: managedObjectContext)
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        var movieID: UUID! = identifier
        if identifier == nil {
            movieID = UUID()
            identifier = movieID
        }
        
        return MovieRepresentation(title: title, identifier: movieID,
                                  hasWatched: hasWatched)
    }
    
}

