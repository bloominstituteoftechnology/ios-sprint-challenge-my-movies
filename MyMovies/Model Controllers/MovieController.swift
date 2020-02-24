import Foundation
import CoreData


/// Firebase Base URL
let firebaseBaseURL = URL(string: "https://lambdaschoolproject.firebaseio.com/")!


class MovieController {
    
    
    // MARK: - Properties
    
    /// Replaces the need to write out the following (below)
    typealias CompletionHandler = (Error?) -> Void
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
    // MARK: - Initializers
    
    init() {
        fetchMovieFromServer()
    }
    
    
    // MARK: - Functions
    
    func fetchMovieFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        // Firebase Base URL + .json on end
        let requestURL = firebaseBaseURL.appendingPathExtension("json")
        
        // Trying to fetch data from URL
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            guard error == nil else {
                print("Error fetch tasks: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            // Decodes Firebase info, sends to UpdateTasks Function (Below)
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateTasks(with: movieRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding task representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    func updateTasks(with representations: [MovieRepresentation]) throws {
         
        // Filters out tasks with no ID
         let moviesWithID = representations.filter { $0.identifier != nil }
         
         let identifiersToFetch = moviesWithID.compactMap { UUID(uuidString: $0.identifier!) }
         
         let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
        
         var moviesToCreate = representationsByID
         
         let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
         
         let context = CoreDataStack.shared.container.newBackgroundContext()
         
         context.perform {
             do {
                 let existingMovies = try context.fetch(fetchRequest)
                 
                 for movie in existingMovies {
                     guard let id = movie.identifier,
                         let representation = representationsByID[id] else { continue }
                     self.update(movie: movie, with: representation)
                     moviesToCreate.removeValue(forKey: id)
                 }
                 
                 for representation in moviesToCreate.values {
                     Movie(movieRepresentation: representation, context: context)
                 }
             } catch {
                 print("Error fetching task for UUIDs: \(error)")
             }
             
             do { try CoreDataStack.shared.save(context: context) }
             catch { print("Error saving to database")}
         }
    }
    
    /// Updates local Task with Firebase representation Data
    private func update(movie: Movie, with representation: MovieRepresentation) {
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
    /// Fetches Movie Search Results & Sets "searchedMovies" object^
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
    
    /// Saves Movie to Persistent Store
    func saveMovie(movie: MovieRepresentation, context: NSManagedObjectContext? = nil) {
        let context = context ?? CoreDataStack.shared.mainContext
        
        let newMovie = Movie(hasWatched: false, identifier: nil, title: movie.title, context: context)
        
        do {
            try CoreDataStack.shared.save(context: context)
            print("Movie saved \(newMovie)")
        } catch {
            print("Error saving \(error)")
        }
        sendMovieToServer(movie: newMovie)
        print("Sending to server")
    }
    
    /// Updates Movie Watched Bool
    func updateWatched(movie: Movie, context: NSManagedObjectContext? = nil) {
        let context = context ?? CoreDataStack.shared.mainContext
        movie.hasWatched.toggle()
        
        do {
            try CoreDataStack.shared.save(context: context)
            print("Movie watched bool updated \(movie.title ?? "No Movie Title Found")")
        } catch {
            print("Error updating watched bool \(error)")
        }
        sendMovieToServer(movie: movie)
    }
    
    /// Saves Movie Locally and shares (json) to Firebase
    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        // Check whether movie has UUID
        let uuid = movie.identifier ?? UUID()
        
        // Create URL Request
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        // Check whether Movie object has appropriate data to send
        do {
            guard var representation = movie
                .movieRepresentation else {
                    completion(NSError())
                    return
            }
            
            representation.identifier = uuid.uuidString
            movie.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encodign movie \(movie): \(error)")
            completion(error)
            return
        }
        
        // Actual URL Request Being Sent
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTting movie to server: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        
        // Lookup Task by UUID
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        // Creates URL Request
        let requestURL = firebaseBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        // Actual URL Request sent to Firebase
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            guard error == nil else {
                print("Error deleting task: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
}
