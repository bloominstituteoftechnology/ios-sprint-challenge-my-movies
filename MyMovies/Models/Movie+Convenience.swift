import Foundation
import CoreData

extension Movie {
    
    
    // MARK: - Initializers
    
    /// Creates Movie with same Managed Object Context "moc"
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
    
    /// Creates Movie from MovieRepresentation Data (aka Firebase JSON data)
    @discardableResult
    convenience init?(movieRepresentation: MovieRepresentation,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifierString = movieRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString) else { return nil }
        
        self.init(hasWatched: movieRepresentation.hasWatched ?? false,
                  identifier: identifier,
                  title: movieRepresentation.title,
                  context: context)
    }
    
    
    // MARK: - Objects
    
    /// Object used to pass Movies back and forward to Firebase in .JSON format
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        return MovieRepresentation(title: title,
                                   identifier: identifier?.uuidString ?? "",
                                   hasWatched: hasWatched)
    }
}
