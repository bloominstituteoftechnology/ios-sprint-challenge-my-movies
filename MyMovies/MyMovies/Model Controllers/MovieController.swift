//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {

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
  func createMovieInCoreData(title: String, identifier: UUID = UUID(), hasWatched: Bool = false) {
    let movie = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
    putMovieToFirebase(movie: movie)
  }
  
  func deleteMovieFromCoreData(movie: Movie) throws {
    let moc = CoreDataManager.shared.mainContext
    var error: Error?
    
    moc.performAndWait {
      moc.delete(movie)
      
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
      } catch let saveError {
        error = saveError
      }
    }
    
    if let error = error {
      throw error
    }
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
  
  // MARK: - Properties
  var searchedMovies: [MovieRepresentation] = []
}
