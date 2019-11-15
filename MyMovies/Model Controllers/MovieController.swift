//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    static var shared = MovieController()
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-20d00.firebaseio.com/")!
    
    // MARK: - CRUD Methods
    
    func createMovieFromRep(movieRepresentation: MovieRepresentation) {
        let context = CoreDataStack.shared.mainContext
        guard let movie = Movie(movieRepresentation: movieRepresentation, context: context) else { return }
        putMoviesOnServer(movie: movie)
    }
    
    func delete(movie: Movie) {
        
        deleteMovieFromServer(movie) { error in
            if let error = error {
                print("Error deleting entry from server: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                let moc = CoreDataStack.shared.mainContext
                moc.delete(movie)
                do {
                    try moc.save()
                } catch {
                    moc.reset()
                    print("Error saving managed object context: \(error)")
                }
            }
        }
    }
    
    func updateMovieWatched(movie: Movie) {
        movie.hasWatched.toggle()
        putMoviesOnServer(movie: movie)
    }
    
    
    // MARK: - Firebase Methods
    
    func putMoviesOnServer(movie: Movie, completion: @escaping () -> Void = { }) {
        let uuid = movie.identifier ?? UUID()
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard let representation = movie.firebaseMovieRep else {
                completion()
                return
            }

            movie.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding movie: \(error)")
            completion()
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            completion()

            if let error = error {
                print("Error PUTing movie to server: \(error)")
            }
        }.resume()
    }

    func deleteMovieFromServer(_ movie: Movie, completion: @escaping (CompletionHandler) = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            context.delete(movie)
            try CoreDataStack.shared.save(context: context)
        } catch {
            context.reset()
            print("Error deleting object from managed object context: \(error)")
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print(response!)
            completion(error)
        }.resume()
    }

    // MARK: - Helper Methods
    
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
    
}
