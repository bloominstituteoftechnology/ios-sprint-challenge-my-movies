
import Foundation
import CoreData

class MovieDataController {
    
    static let shared = MovieDataController()
    
    typealias  CompletionHandler = (Error?) -> Void
    
    let baseURL = URL(string: "https://mymovies-59952.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
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
        put(movie: newMovie)
        
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
        put(movie: movie)
        
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)

        // Save this deletion to the persistent store
        saveToPersistentStore()
        
        // Save this deletion on the server
        deleteMovieFromServer(movie: movie)
        
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
            
            // Should this encode (movie)?
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
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        
        // Perform this function on background
        guard let context = movie.managedObjectContext else { return }
        
        context.perform {
            guard movie.identifier == representation.identifier else {
                fatalError("Updating the wrong movie!")
            }
            
            // hasWatched is optional - give it a default
            movie.hasWatched = representation.hasWatched ?? false
        }

    }
    
    // Fetch from Core Data - Perform on background
    func fetchSingleMovieFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Movie? {
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        request.predicate = predicate
        
        var movie: Movie?
        context.performAndWait {
            
            // Return first movie from the array
            movie = (try? context.fetch(request))?.first
        }
        
        return movie
    }
    
    // Fetch from Core Data
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        // Perform a GET URLSessionDataTask with url
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from the data task")
                completion(NSError())
                return
            }
            
//            guard let representation = movie.movieRepresentation else { throw NSError() }
//
//            let uuid = representation.identifier?.uuidString
            
            // Use container to get a new background context
            let moc = CoreDataStack.shared.container.newBackgroundContext()
            
            var dataArray: [MovieRepresentation] = []
            
                do {
                    dataArray = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                    
                    for eachMovie in dataArray {
                        
                        // Assign to the result of the fetchSingleMovie func so that we can compare it to the movie representation.
                        // This checks to see if there is already a corresponding movie in the persistent store
                        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: (eachMovie.identifier?.uuidString)!, context: moc) {
                            self.update(movie: movie, with: eachMovie)
                        } else {
                            
                            // If they are the same, we dont' need to do anything
                            
                            // But if there was no movie returned, that means the server has an movie that the device doesn't have.
                            // So initialize a new Movie using the convenience initializer that takes in a Movie Representation
                            moc.perform {
                                _ = Movie(movieRepresentation: eachMovie, context: moc)
                            }

                        }
                        
                    }
                    
                    try CoreDataStack.shared.saveTo(context: moc)
                    completion(nil)
                    
                } catch {
                    NSLog("Error decoding or importing tasks: \(error)")
                    completion(error)
                }
            
        }.resume()
    }
    
    // Delete from server
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        do {
            guard let representation = movie.movieRepresentation else { throw NSError() }
            
            let uuid = representation.identifier?.uuidString
            
            // Append identifier of the entry parameter to the baseURL
            let requestURL = baseURL.appendingPathComponent(uuid!).appendingPathExtension("json")
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { (_, _, error) in
                if let error = error {
                    NSLog("Error deleting movie: \(error)")
                }
                completion(error)
            }.resume()
            
            
        } catch {
            NSLog("Error encoding task: \(error)")
            completion(error)
            return
        }

        
    }
}
