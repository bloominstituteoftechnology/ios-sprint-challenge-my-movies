//
//  MovieFirebaseController.swift
//  MyMovies
//
//  Created by Clayton Watkins on 6/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError2: Error{
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

class MovieFirebaseController {
    //MARK: - Properties
    private let firebaseURL = URL(string: "https://movies-df196.firebaseio.com/")!
    typealias CompletionHandler = (Result<Bool, NetworkError2>) -> Void
    
    //MARK: - Initializer
    init(){
        self.fetchMoviesFromFirebase()
    }
    
    // MARK: - Movies Firebase Network Functions
    // Adding movies to our Firebase / also gets called when updating the hasWatched bool
    func addMovieToFirebase(movie: Movie, completion: @escaping CompletionHandler = { _ in }){
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do{
            guard let representation = movie.movieRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding Movie \(movie): \(error)")
            completion(.failure(.noEncode))
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error{
                print("Error putting task to server: \(error)")
                completion(.failure(.otherError))
            }
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
    //Fetching/Updating movies from Firebase in order to sync
    func fetchMoviesFromFirebase(completion: @escaping CompletionHandler = { _ in }){
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error{
                print("Error fetching movies: \(error)")
                completion(.failure(.otherError))
            }
            
            guard let data = data else{
                print("No data returned by data task")
                completion(.failure(.noData))
                return
            }
            
            do{
                let movieRepresentation = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentation)
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                print("Error decoding task representation: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.noDecode))
                }
            }
        }.resume()
    }
    
    //Removing movies from Firebase
    func deleteMovieFromFirebase(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }){
        guard let uuid = movie.identifier else{
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
    //MARK: - Private Functions
    // Creating a representation of our Movie object
    private func update(movie: Movie, with representation: MovieRepresentation){
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }
    
    private func updateMovies(with representations: [MovieRepresentation]) throws {
        // Creating a new CoreData context so that we aren't saving to the main context while performing a URLSession
        let context = CoreDataStack.shared.container.newBackgroundContext()
        // Array of UUIDs
        let identifiersToFetch = representations.compactMap({ $0.identifier })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        context.performAndWait {
            do{
                let existingMovies = try context.fetch(fetchRequest)
                
                //For our already existing Movies
                for movie in existingMovies{
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }
                    //Update Movie
                    self.update(movie: movie, with: representation)
                    moviesToCreate.removeValue(forKey: id)
                }
                
                for representation in moviesToCreate.values{
                    Movie(movieRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching movies for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save()
    }
}
