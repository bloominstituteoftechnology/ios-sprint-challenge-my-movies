
import Foundation
import CoreData

class MovieDataController {
    
    typealias  CompletionHandler = (Error?) -> Void
    
    let baseURL = URL(string: "https://mymovies-59952.firebaseio.com/")!
    
    
    // MARK: - Core Data Functions
    
    // Does this need an identifier?
    func createMovie(title: String, hasWatched: Bool) {
        
        // Initialize a Movie object
        let newMovie = Movie(context: CoreDataStack.shared.mainContext)
        
        newMovie.title = title
        newMovie.hasWatched = hasWatched
        
        // Save to the persistent store
        saveToPersistentStore()
        
        // Save to the server (PUT)
        
    }
    
    // Saves CoreDataStack's mainContext to the Persistent Store
    func saveToPersistentStore() {
        
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save()
        } catch {
            fatalError("Error saving to core data: \(error)")
        }
    }
    
    // Do I need identifier here?
    func updateMovie(movie: Movie, hasWatched: Bool) {
        
        // Change the hasWatched bool
        movie.hasWatched = hasWatched
        
        // Save changes to the persistent store
        saveToPersistentStore()
        
        // Save to the server (PUT)
        
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)

        // Save this deletion to the persistent store
        saveToPersistentStore()
        
        // Save to the server
        
    }
    
    // MARK: - Firebase Functions
    
    // Save to the server
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        do {
            
            guard let representation = movie.movieRepresentation else { throw NSError() }
            
            let uuid = representation.identifier?.uuidString
            let requestURL = baseURL.appendingPathComponent(uuid!).appendingPathExtension("json")
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            
            // Should this encode (movie)
            let body = try JSONEncoder().encode(representation)
            request.httpBody = body
            
            URLSession.shared.dataTask(with: request) { (_, _, error) in
                if let error = error {
                    NSLog("Error saving movie: \(error)")
                }
                completion(error)
            }.resume()
            
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion(error)
            return
            
        }
        
        
        
        
        
    }
    
    
    
    
    
    
    func loadFromPersistentStore() -> [Movie] {

        var movie: [Movie] {
            do {
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                let result = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
                return result
            } catch {
                fatalError("Can't fetch Data \(error)")
            }


        }
        return movie

        
    }
    
    
    
    
    
}
