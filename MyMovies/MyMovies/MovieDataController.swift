
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
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        
        guard movie.identifier == representation.identifier else {
            fatalError("Updating the wrong movie!")
        }
        
        // Unwrap hasWatched bool b/c it's optional
        guard let hasWatchedRepresentation = representation.hasWatched else { return }
        
        movie.hasWatched = hasWatchedRepresentation
        movie.identifier = representation.identifier
    
    }
    
    // Fetch from Core Data
    func fetchSingleMovieFromPersistentStore(identifier: String) -> Movie? {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        request.predicate = predicate
        
        let moc = CoreDataStack.shared.mainContext
        
        // Return first movie from the array
        let movie = (try? moc.fetch(request))?.first
        
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
            
            let moc = CoreDataStack.shared.mainContext
            
            var dataArray: [MovieRepresentation] = []
            
            DispatchQueue.main.async {
                do {
                    dataArray = try JSONDecoder().decode([String: MovieRepresentation].self, from: data).map({$0.value})
                    
                    for eachMovie in dataArray {
                        
                        // Assign to the result of the fetchSingleMovie func so that we can compare it to the movie representation.
                        // This checks to see if there is already a corresponding movie in the persistent store
                        if let movie = self.fetchSingleMovieFromPersistentStore(identifier: (eachMovie.identifier?.uuidString)!) {
                            self.update(movie: movie, with: eachMovie)
                        } else {
                            
                            // If they are the same, we dont' need to do anything
                            
                            // But if there was no movie returned, that means the server has an movie that the device doesn't have.
                            // So initialize a new Movie using the convenience initializer that takes in a Movie Representation
                            _ = Movie(movieRepresentation: eachMovie)
                        }
                        
                    }
                    
                    self.saveToPersistentStore()
                    completion(nil)
                    
                } catch {
                    NSLog("Error decoding or importing tasks: \(error)")
                    completion(error)
                }
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
