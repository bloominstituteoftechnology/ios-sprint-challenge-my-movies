import Foundation
import CoreData

class MovieController {
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    
    // MARK: - Functions
    
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
    func saveMovie(movie: MovieRepresentation) {
        let moc = CoreDataStack.shared.mainContext
        let newMovie = Movie(hasWatched: false, identifier: nil, title: movie.title, context: moc)
        
        do {
            try moc.save()
            print("Movie saved \(newMovie)")
        } catch {
            print("Error saving \(newMovie)")
        }
    }
    
    /// Update Movie Watched Bool
    func updateWatched(movie: Movie) {
        let moc = CoreDataStack.shared.mainContext
        movie.hasWatched.toggle()
        
        do {
            try moc.save()
            print("Movie watched bool updated \(movie.title ?? "No Movie Title Found")")
        } catch {
            print("Error updating watched bool \(error)")
        }
    }
}
