import Foundation
import CoreData

let firebaseURL = URL(string: "https://moses-mymovies.firebaseio.com/")!

// base for Movie API
private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    func saveToPersistentStore() {
        
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func put(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            
            request.httpBody = try JSONEncoder().encode(movie)
            
        } catch {
            NSLog("Error enconding entry: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            if let error = error {
                NSLog("Error PUTing entry to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func createMovie(title: String) {
        
        let movie = Movie(title: title)
        
        saveToPersistentStore()
        put(movie: movie)
    }
    
    func updateMovie(movie: Movie, hasWatched: Bool) {
        
        movie.hasWatched = hasWatched
        
        saveToPersistentStore()
        put(movie: movie)
    }
    
    func updateWithRep(movie: Movie, with movieRepresentation: MovieRepresentation) {
        guard let moc = movie.managedObjectContext else { return }
        
        moc.performAndWait {
            movie.title = movieRepresentation.title
            movie.identifier = movieRepresentation.identifier
            movie.hasWatched = movieRepresentation.hasWatched ?? false
        }
        
    }
    
    func deleteMovie(movie: Movie) {
        
        deleteMovieFromServer(movie: movie)
        
        let moc = CoreDataStack.shared.mainContext
        moc.delete(movie)
        
        saveToPersistentStore()
        
    }
    
    func deleteMovieFromServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        guard let identifier = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting movie: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
                
            }
            
            let moc = CoreDataStack.shared.container.newBackgroundContext()
            
            do {
                let movieRepresentationsDict = try JSONDecoder().decode([String : MovieRepresentation].self, from: data)
                let movieRepresentations = Array(movieRepresentationsDict.values)
                
                
                for movieRep in movieRepresentations {
                    guard let identifier = movieRep.identifier else { return }
                    
                    if let movie = self.fetchSingleMovieFromPersistentStore(identifier: identifier, in: moc) {
                        // We already have a local movie for this
                        self.updateWithRep(movie: movie, with: movieRep)
                    } else {
                        // Need to create a new movie in Core Data
                        moc.perform {
                            let _ = Movie(movieRepresentation: movieRep, context: moc)
                        }
                    }
                }
                
                try CoreDataStack.shared.save(context: moc)
                
            } catch {
                NSLog("Error decoding tasks: \(error)")
                completion(error)
                return
            }
            completion(nil)
            
            
            }.resume()
    }
    
    func fetchSingleMovieFromPersistentStore(identifier: UUID, in context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        
        var result: Movie?
        context.performAndWait {
            result = (try? context.fetch(fetchRequest))?.first
        }
        return result
    }
    
    
    
    
    
    // MOVIE API `GET`
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
            }.resume()
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
