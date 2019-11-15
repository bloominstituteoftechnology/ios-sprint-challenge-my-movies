//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    
    static var shared = MovieController()
    
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-20d00.firebaseio.com/")!
    
    init() {
        fetchMoviesFromServer()
    }
    
    // MARK: - CRUD Methods
    
    func createMovieFromRep(movieRepresentation: MovieRepresentation) {
        let context = CoreDataStack.shared.mainContext
        guard let movie = Movie(movieRepresentation: movieRepresentation, context: context) else { return }
        putMoviesOnServer(movie: movie)
    }
    
    func createMovieFromFirebaseRep(firebaseRep: FirebaseMovieRep) {
        let context = CoreDataStack.shared.mainContext
        guard let movie = Movie(firebaseRep: firebaseRep, context: context) else { return }
        putMoviesOnServer(movie: movie)
    }
    
    func delete(movie: Movie) {
        
        deleteMovieFromServer(movie) { error in
            if let error = error {
                print("Error deleting movie from server: \(error)")
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
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            if let error = error {
                print("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                print("No data returned by movie")
                completion(NSError())
                return
            }
            
            do {
                let firebaseRepresentations = Array(try JSONDecoder().decode([String : FirebaseMovieRep].self, from: data).values)
                try self.updateMovies(with: firebaseRepresentations)
            } catch {
                print("Error decoding movie representations: \(error)")
                completion(error)
                return
            }
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
    
    private func update(movie: Movie, with fireRep: FirebaseMovieRep) {
        movie.title = fireRep.title
        movie.hasWatched = fireRep.hasWatched
    }
    
    private func updateMovies(with representations: [FirebaseMovieRep]) throws {
        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier) }
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var moviesToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        do {
            let existingMovies = try context.fetch(fetchRequest)
            
            for movie in existingMovies {
                guard let id = movie.identifier,
                    let representation = representationsByID[id] else { continue }
                
                self.update(movie: movie, with: representation)
                moviesToCreate.removeValue(forKey: id)
            }
            
            for representation in moviesToCreate.values {
                Movie(firebaseRep: representation)
            }
        } catch {
            print("Error fetching movies for UUIDs: \(error)")
        }
        
        try CoreDataStack.shared.save(context: context)
    }
}
