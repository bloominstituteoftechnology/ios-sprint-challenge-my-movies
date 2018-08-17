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

  func createMovie(title: String, identifier: UUID = UUID(), hasWatched: Bool = false) {
    let _ = Movie(title: title, identifier: identifier, hasWatched: hasWatched)
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
  // MARK: - Properties

  var searchedMovies: [MovieRepresentation] = []
}
