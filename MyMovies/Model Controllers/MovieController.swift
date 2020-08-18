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
    private let fireBaseURL = URL(string: "https://mymovie-6338d.firebaseio.com/")!

    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void

    // MARK: - Properties

    var searchedMovies: [MovieDBMovie] = []

    init() {
//        fetchMovieFromServer()
    }

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

    func fetchMovieFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = fireBaseURL.appendingPathExtension("json")

        let movie = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(.failure(.otherError))
                return
            }

            guard let data = data else {
                print("No data returned by data task")
                completion(.failure(.noData))
                return
            }

            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovie(with: movieRepresentations)
                completion(.success(true))
            } catch {
                print("Error decoding task representations: \(error)")
                completion(.failure(.failedDecode))
                return
            }
        }
        movie.resume()
    }

    func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
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

        let moviesWithID = representations.filter {
            $0.identifier != nil
        }

        let identifiersToFetch = moviesWithID.compactMap({$0.identifier})

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var movieToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)


        context.performAndWait {
            do {
                let exisitingMovie = try context.fetch(fetchRequest)

                for movie in exisitingMovie {
                    guard let id = movie.identifier?.uuidString,
                        let representation = representationsByID[id] else { continue }

                    self.update(movie: movie, with: representation)

                    movieToCreate.removeValue(forKey: id)
                }

                for representation in movieToCreate.values {
                    Movie(movieRespresentation: representation, context: context)
                }
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: context)
    }

    private func update(movie: Movie, with represenation: MovieRepresentation) {
        movie.title = represenation.title
        movie.hasWatched = represenation.hasWatched
    }

    func sendMovieToServer(movie: Movie,completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = movie.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = fireBaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard let representation = movie.movieRepresentations else {
                completion(.failure(.noRep))
                return
            }

            request.httpBody = try JSONEncoder().encode(representation)
        } catch {

            print("Error encoding movie \(movie): \(error)")
            completion(.failure(.failedEncode))
            return
        }

        let movie = URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error puttin task to server: \(error)")
                completion(.failure(.otherError))
                return
            }

            completion(.success(true))
        }

        movie.resume()
    }

}
