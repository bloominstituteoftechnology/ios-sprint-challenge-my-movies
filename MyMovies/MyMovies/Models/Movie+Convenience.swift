import Foundation
import CoreData

extension Movie {
    convenience init(title: String,
                     identifier: UUID = UUID(),
                     hasWatched: Bool = false,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched
    }
    
    convenience init(movieRepresentation: MovieRepresentation,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(title: movieRepresentation.title,
                  identifier: movieRepresentation.identifier ?? UUID(),
                  hasWatched: movieRepresentation.hasWatched ?? false,
                  context: context)
    }
}
