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
    
    //MARK: baseURL
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseBaseURL = URL(string: "https://mymovies-66ef3.firebaseio.com/")!
    
    //MARK: SearchForMovie
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
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
    
    var coreDataStack: CoreDataStack?
       
       // Using this initializer as the "viewDidLoad" of the EntriesController
       init() {
           fetchMoviesFromServer()
       }
       
       //MARK: Firebase Networking
       
       // MARK:PUT Movies to Firebase
       //TODO: Return en optional Error ???
       func put(movie: Movie, completion: @escaping () -> Void = { }) {
           
        
           let identifier = movie.identifier ?? UUID()
           movie.identifier = identifier
           
           let requestURL = firebaseBaseURL
               .appendingPathComponent(identifier.uuidString)
               .appendingPathExtension("json")
           
           var request = URLRequest(url: requestURL)
           request.httpMethod = HTTPMethod.put.rawValue
           
           guard let movieRepresentation = movie.movieRepresentation else {
               NSLog("Movie Representation is nil")
               completion()
               return
           }
           
           do {
               request.httpBody = try JSONEncoder().encode(movieRepresentation)
           } catch {
               NSLog("Error encoding movie representation: \(error)")
               completion()
               return
           }
           
           // data task
           URLSession.shared.dataTask(with: request) { (_, _, error) in
               
               if let error = error {
                   NSLog("Error PUTting movie: \(error)")
                   completion()
                   return
               }
               completion()
           }.resume()
       }
       
       
       //MARK: DeleteFromServer
       func deleteFromServer(movie: Movie, completion: @escaping () -> Void? = { }) {
           
           let identifier = movie.identifier ?? UUID()
           movie.identifier = identifier
           
           let requestURL = baseURL
               .appendingPathComponent(identifier.uuidString)
               .appendingPathExtension("json")
           
           var request = URLRequest(url: requestURL)
           request.httpMethod = HTTPMethod.delete.rawValue
           
           guard let movieRepresentation = movie.movieRepresentation else {
               NSLog("Movie Representation is nil")
               completion()
               return
           }
           
           do {
               request.httpBody = try JSONEncoder().encode(movieRepresentation)
           } catch {
               NSLog("Error encoding movie representation: \(error)")
               completion()
               return
           }
           
           //data task
           URLSession.shared.dataTask(with: request) { (_, _, error) in
               
               if let error = error {
                   NSLog("Error PUTting movie: \(error)")
                   completion()
                   return
               }
               completion()
           }.resume()
       }
       
       //MARK: FetchMoviesFromServer
       func fetchMoviesFromServer(completion: @escaping () -> Void = { }) {
           
           // Set up the URL
           
           let requestURL = baseURL.appendingPathExtension("json")
           
           // Create the URLRequest
           
           var request = URLRequest(url: requestURL)
           request.httpMethod = HTTPMethod.get.rawValue
           
           // Perform the data task
           URLSession.shared.dataTask(with: request) { (data, _, error) in
               
               // Check for errors
               
               if let error = error {
                   NSLog("Error fetching movies: \(error)")
                   completion()
                   return
               }
               
               // Decode the data
               
               guard let data = data else {
                   NSLog("No data returned from movie fetch data task")
                   completion()
                   return
               }
               
               let decoder = JSONDecoder()
               
               do {
                   
                   let movies = try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                   
                   // Figure out the entries that need to be created, and the ones that need to be updated
                   self.updateMovies(with: movies)
                   
               } catch {
                   NSLog("Error decoding MovieRepresenations: \(error)")
               }
               completion()
           }.resume()
       }
       
       //MARK: UpdateMovie (server)
       //fetched from server, then called PUT
    func updateMovie(movie: Movie, title: String, hasWatched: Bool, context: NSManagedObjectContext) {
        
        movie.title = title
        movie.hasWatched = hasWatched
        CoreDataStack.shared.save(context: context)

           put(movie: movie)
       }
    
       //MARK: UpdateEntries (server)
       func updateMovies(with representations: [MovieRepresentation]) {
           
           // Which representations do we already have in Core Data?
           //Creating an Array of the representation's identifiers
           let identifiersToFetch = representations.map({ $0.identifier })
           
           // [[UUID]: [MovieRepresentation]]
           let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
           
           // Make a mutable copy of the dictionary above
           
           // How many movies (that could need to be created OR updated)
           var moviesToCreate = representationsByID
           let context = CoreDataStack.shared.container.newBackgroundContext()
           
           context.performAndWait {
               
               do {
                  
                   let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                   
                   // Only fetch the movies with the identifiers that are in this identifiersToFetch array
                                                       //"identifiersToFetch.contains(identifier)"
                   fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                   
                   let existingMovies = try context.fetch(fetchRequest)
                   
                   //MARK: Update the ones we do have
                   
                   // Movie
                   for movie in existingMovies {
                       
                       // Grab the MovieRepresentation that corresponds to this Movie
                       guard let identifier = movie.identifier,
                           let representation = representationsByID[identifier] else { continue }
                       
                       update(movie: movie, movieRepresentation: representation)
                       // We just updated a movie, we don't need to create a new Movie for this identifier
                       moviesToCreate.removeValue(forKey: identifier)
                   }
              
                   //MARK: Figure out which ones we don't have
                   
                   // movies that don't exist in Core Data already
                   for representation in moviesToCreate.values {
                       Movie(movieRepresentation: representation, context: context)
                   }
                   
                   // Persist all the changes (updating and creating of movies) to Core Data
                   CoreDataStack.shared.save(context: context)
               } catch {
                   NSLog("Error fetching movies from persistent store: \(error)")
               }
           }
       }
       
       //MARK: CRUD
       
       //Create
       
    func createMovie(title: String, hasWatched: Bool, context: NSManagedObjectContext) {
        
        let newMovie = Movie(title: title, hasWatched: hasWatched, context: context)
        
           put(movie: newMovie)
       }
       
       //Update
       
       func update(movie: Movie, movieRepresentation: MovieRepresentation) {
        
        movie.title = movieRepresentation.title
        movie.hasWatched = movieRepresentation.hasWatched ?? false
          }
       
       //Delete
       
       func deleteMovie(movie: Movie, context: NSManagedObjectContext) {
           context.performAndWait {
               deleteFromServer(movie: movie)
               context.delete(movie)
               CoreDataStack.shared.save(context: context)
           }
       }
}

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}
