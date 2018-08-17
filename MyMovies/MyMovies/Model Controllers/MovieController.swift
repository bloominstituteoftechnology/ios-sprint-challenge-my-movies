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

  init() {
    fetchMoviesFromServer()
  }

  private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
  private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
  private let firebaseURL = URL(string: "https://mymovies-bd8d2.firebaseio.com/")!
  typealias CompletionHandler = (Error?) -> Void

  // API funcs
  func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {

    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)

    let queryParameters = ["query": searchTerm,
      "api_key": apiKey]

    components?.queryItems = queryParameters.map({ URLQueryItem(name: $0.key, value: $0.value) })

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

  // Core Data funcs
  func fetchSingleMovieFromCoreData(identifier: UUID, context: NSManagedObjectContext) -> Movie? {
    let request: NSFetchRequest<Movie> = Movie.fetchRequest()
    request.predicate = NSPredicate(format: "identifier == %@", identifier.uuidString)
    do {
      return try context.fetch(request).first
    } catch {
      NSLog("Error fetching entry with identifier: \(identifier) - \(error)")
      return nil
    }
  }

  func createMovieInCoreData(title: String, identifier: UUID = UUID(), hasWatched: Bool = false) {
    let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
    putMovieToFirebase(movie: movie)
  }

  func deleteMovieFromCoreData(movie: Movie) throws {
    let moc = CoreDataManager.shared.mainContext
    var error: Error?

    moc.performAndWait {
      moc.delete(movie)
      self.deleteMovieFromFirebase(movie: movie)
      do {
        try moc.save()
      } catch let saveError {
        error = saveError
      }
    }

    if let error = error {
      throw error
    }
  }

  func updateMovieInCoreData(movie: Movie) throws {
    let moc = CoreDataManager.shared.mainContext
    var error: Error?

    moc.performAndWait {
      movie.hasWatched = !movie.hasWatched
      do {
        try moc.save()
        self.putMovieToFirebase(movie: movie)
      } catch let saveError {
        error = saveError
      }
    }

    if let error = error {
      throw error
    }
  }

  func update(movie: Movie, movieRep: MovieRepresentation) {
    guard let hasWatched = movieRep.hasWatched else { return }
    movie.title = movieRep.title
    movie.identifier = movieRep.identifier
    movie.hasWatched = hasWatched
  }

  func saveToPersistentStore() {
    do {
      let moc = CoreDataManager.shared.mainContext
      try moc.save()
    } catch {
      NSLog("Error saving managed object context: \(error)")
    }
  }

  // Firebase funcs

  func putMovieToFirebase(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
    let identifier = movie.identifier ?? UUID()
    let url = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "PUT"

    do {
      let encoder = JSONEncoder()
      urlRequest.httpBody = try encoder.encode(movie)
    } catch {
      NSLog("Error with encoding movie: \(error)")
    }

    URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
      if let error = error {
        NSLog("Error with PUTting data: \(error)")
        completion(error)
        return
      }

      completion(nil)
    }.resume()
  }

  func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
    let url = firebaseURL.appendingPathExtension("json")

    URLSession.shared.dataTask(with: url) { (data, _, error) in
      if let error = error {
        NSLog("Error with GETting data: \(error)")
        completion(error)
        return
      }

      guard let data = data else {
        NSLog("No data returned by data task")
        completion(NSError())
        return
      }

      var movieRepresentations: [MovieRepresentation] = []

      do {
        let decoder = JSONDecoder()
        let jsonEntries = try decoder.decode([String: MovieRepresentation].self, from: data)
        movieRepresentations = jsonEntries.values.map { $0 }

        let backgroundMOC = CoreDataManager.shared.container.newBackgroundContext()
        try self.updateMoviesFromServer(with: movieRepresentations, context: backgroundMOC)
        completion(nil)
      } catch let error {
        NSLog("Error decoding data: \(error)")
      }
    }.resume()
  }

  func deleteMovieFromFirebase(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
    let identifier = movie.identifier ?? UUID()
    let url = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "DELETE"

    URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
      if let error = error {
        NSLog("Could not delete \(movie) from server: \(error)")
        completion(error)
        return
      }

      completion(nil)
    }.resume()
  }


  func updateMoviesFromServer(with movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) throws {
    var error: Error?

    context.performAndWait {
      for movieRep in movieRepresentations {
        guard let identifier = movieRep.identifier else { continue }
        if let movie = self.fetchSingleMovieFromCoreData(identifier: identifier, context: context) {
          if !(movie == movieRep) {
            self.update(movie: movie, movieRep: movieRep)
          }
        } else {
          let _ = Movie(movieRepresentation: movieRep, context: context)
        }
      }

      do {
        try context.save()
      } catch let saveError {
        error = saveError
      }
    }

    if let error = error {
      throw error
    }
  }

  // MARK: - Properties
  var searchedMovies: [MovieRepresentation] = []
}
