
import Foundation
import CoreData

extension Movie {
    
    convenience init(title: String, identifier: UUID = UUID(), hasWatched: Bool, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        
        self.title = title
        self.identifier = identifier
        
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title else { return nil }
        
        var movieID: UUID! = identifier
        if identifier == nil {
            movieID = UUID()
            identifier = movieID
        }
        
        return MovieRepresentation(title: title, identifier: movieID, hasWatched: hasWatched)
    }
    
    
}
