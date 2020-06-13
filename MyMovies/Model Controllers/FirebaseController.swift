//
//  FirebaseController.swift
//  MyMovies
//
//  Created by Bohdan Tkachenko on 6/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkErrors: Error {
    case noIdentifier, otherError, noRep, noEncode, noDecode, noData
}


class FirebaseController {
    
    //MARK: Propertirs
    
    private let firebaseURL = URL(string: "https://mymovies-2d0bb.firebaseio.com/")!
    
    typealias CompletionHandler = (Result<Bool, NetworkErrors>) -> Void

     //MARK: - Initializer
    
    init(){
        self.fetchMoviesFromFirebase()
    }

     // MARK: - Movies Firebase Network Functions

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

     // Fetching - Updating
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

     //Removing movies
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

    private func update(movie: Movie, with representation: MovieRepresentation){
        movie.title = representation.title
        movie.hasWatched = representation.hasWatched ?? false
    }

     private func updateMovies(with representations: [MovieRepresentation]) throws {
        
        let context = CoreDataStack.shared.container.newBackgroundContext()

        let identifiersToFetch = representations.compactMap({ $0.identifier })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var moviesToCreate = representationsByID
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        context.performAndWait {
            do{
                let existingMovies = try context.fetch(fetchRequest)


                for movie in existingMovies{
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }

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
