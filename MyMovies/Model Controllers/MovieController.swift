//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case otherError
    case noData
    case failedDecode
    case failedEncode
    case noIdentifier
    case noRep
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    // MARK: - Properties
    
    var searchedMovies: [MovieDBMovie] = []
    
    // MARK: - TheMovieDB API
    
    func searchForMovie(with searchTerm: String, completion: @escaping CompletionHandler) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieDBMovies = try JSONDecoder().decode(MovieDBResults.self, from: data).results
                self.searchedMovies = movieDBMovies
                completion(.success(true))
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(.failure(.failedDecode))
            }
        }.resume()
    }

    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        let movie = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(.success(true))
        }
        movie.resume()
    }

    private func updateMovie(with representations: [MovieRepresentation]) throws {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        let identifiersToFetch = representations.compactMap({UUID(uuidString: $0.identifier)})

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var taskToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let contexts = CoreDataStack.shared.mainContext

        context.performAndWait {
            do {
                let exisitingTasks = try contexts.fetch(fetchRequest)

                for movie in exisitingTasks {
                    guard let id = movie.identifier,
                        let representation = representationsByID[id] else { continue }

                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched

                    taskToCreate.removeValue(forKey: id)
                }

                for representation in taskToCreate.values {
                    Movie(movieRespresentation: representation, context: contexts)
                }
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: context)
    }
}
