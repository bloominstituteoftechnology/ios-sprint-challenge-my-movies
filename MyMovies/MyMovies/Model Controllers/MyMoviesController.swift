import Foundation
import CoreData

class MyMoviesController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    private let baseURL = URL(string: "https://ios-sprint-4-mymovies.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("no data returned from the data task")
                completion(NSError())
                return
            }
            
            let moc = CoreDataStack.shared.container.newBackgroundContext()
            do {
                let decodedResponse = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
                let movieRepresentations = Array(decodedResponse.values)
                
                self.importMoviesFromServer(movieRepresentations, into: moc)
                
                try CoreDataStack.shared.save(context: moc)
                
                completion(nil)
                
            } catch {
                print("error decoding movies: \(error)")
                completion(error)
            }
            }.resume()
    }
    
    func saveMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        do {
            guard let representation = movie.movieRepresentation else { throw NSError() }
            
            let uuid = representation.identifier?.uuidString
            let requestURL = baseURL.appendingPathComponent(uuid!).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            request.httpBody = try JSONEncoder().encode(representation)
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    print("error saving movie: \(error)")
                }
                completion(error)
                }.resume()
        } catch {
            print("error encoding movie: \(error)")
            completion(error)
            return
        }
    }
    
    func deleteMovieFromServer(movieWithIdentifier: UUID, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movieWithIdentifier.uuidString
        
        let requestURL = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("error deleting movie: \(error)")
            }
            completion(error)
            }.resume()
    }
    
    func importMoviesFromServer(_ representations: [MovieRepresentation], into managedObjectContext: NSManagedObjectContext) {
        var importedMovieIdentifiers = Set<String>()
        
        for representation in representations {
            if let existing = fetchMovieFromServer(for: representation.identifier!, in: managedObjectContext) {
                update(movie: existing, with: representation)
                importedMovieIdentifiers.insert((representation.identifier?.uuidString)!)
            } else {
                managedObjectContext.perform {
                    _ = Movie(representation: representation, managedObjectContext: managedObjectContext)
                }
            }
        }
        
        let query: NSFetchRequest<NSFetchRequestResult> = Movie.fetchRequest()
        
        // find all the movies with identifiers that were NOT updated
        query.predicate = NSPredicate(format: "identifier != NULL AND NOT(identifier IN %@)", importedMovieIdentifiers)
        
        let batchDelete = NSBatchDeleteRequest(fetchRequest: query)
        
        managedObjectContext.perform {
            _ = try? managedObjectContext.execute(batchDelete)
        }
    }
    
    func fetchMovieFromServer(for uuid: UUID, in managedObjectContext: NSManagedObjectContext) -> Movie? {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
        
        var movie: Movie?
        
        managedObjectContext.performAndWait {
            movie = (try? managedObjectContext.fetch(request))?.first
        }
        
        return movie
    }
    
    func update(movie: Movie, with representation: MovieRepresentation) {
        guard let context = movie.managedObjectContext else { return }
        
        context.perform {
            guard movie.identifier == representation.identifier else {
                fatalError("unable to update")
            }
            
            movie.title = representation.title
            movie.hasWatched = representation.hasWatched!

        }
    }
     var movieRepresentations: [MovieRepresentation] = []
}

