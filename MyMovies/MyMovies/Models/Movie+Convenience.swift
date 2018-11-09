import Foundation
import CoreData

enum WatchedStatus: String {
    case watched = "Watched"
    case notWatched = "Not Watched"
}

extension Movie {
    
    convenience init(title: String, hasWatched: Bool, identifier: UUID = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else { return nil }
        
        self.init(title: movieRepresentation.title, hasWatched: hasWatched, identifier: identifier, context: context)
    }
    
    var movieRepresentation: MovieRepresentation? {
        
        guard let title = title,
            let identifier = identifier else { return nil }
        
        return MovieRepresentation(title: title, hasWatched: hasWatched, identifier: identifier)
        
    }
}
