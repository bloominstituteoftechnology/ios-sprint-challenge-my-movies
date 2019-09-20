//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}


class MovieController {
    
    init(){
        fetchMovieFromServer()
    }
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    let fireBaseURL = URL(string: "https://movies-f2bd9.firebaseio.com/")!
    
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
    }//End of SearchForMovie func
    
    
    func put(movie: Movie, completion: @escaping()-> Void = {}) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        guard let movieRepresentation = movie.movieRepresentation else{
            NSLog("Error")
            completion()
            return
        }
        
        do{
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            NSLog("Error encoding movie: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error{
                NSLog("Error putting movie: \(error)")
                completion()
                return
            }
            completion()
            }.resume()
        
        
    }
    
    
    func fetchMovieFromServer(completion: @escaping()-> Void = {}) {
        
        
        
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error{
                NSLog("error fetching movie: \(error)")
                completion()
            }
            
            guard let data = data else{
                NSLog("Error getting data movie:")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                //Gives us full array of task representation
                let movieRepresentations = Array(try decoder.decode([String: MovieRepresentation].self, from: data).values)
                
                self.update(with: movieRepresentations)
                
                
                
            } catch {
                NSLog("Error decoding: \(error)")
                
            }
            
            }.resume()
        
        
    }
    
    func update(with representations: [MovieRepresentation]){
        
        
        let identifiersToFetch = representations.compactMap({ ($0.identifier)})
        
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        //Make a mutable copy of Dictionary above
        var moviesToCreate = representationsByID
        
        
        let context = CoreDataStack.share.container.newBackgroundContext()
        context.performAndWait {
            
            
            
            do {
                
                let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                //Name of Attibute
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                
                //Which of these tasks already exist in core data?
                let exisitingMovie = try context.fetch(fetchRequest)
                
                //Which need to be updated? Which need to be put into core data?
                for movie in exisitingMovie {
                    guard let identifier = movie.identifier,
                        // This gets the task representation that corresponds to the task from Core Data
                        let representation = representationsByID[identifier] else{return}
                    
                    movie.title = representation.title
                    movie.hasWatched = representation.hasWatched ?? true
                    
                    moviesToCreate.removeValue(forKey: identifier)
                    
                }
                //Take these tasks that arent in core data and create
                for representation in moviesToCreate.values{
                    Movie(movieRepresentation: representation, context: context)
                }
                
                CoreDataStack.share.save(context: context)
                
            } catch {
                NSLog("Error fetching tasks from persistent store: \(error)")
            }
        }
        
    }
    
    
    
    
    
    
    //CRUD
    
    @discardableResult func createTask(with title: String, hasWatched: Bool?) -> Movie {
        let movie = Movie(title: title, hasWatched: hasWatched, context: CoreDataStack.share.mainContext)
        
        put(movie: movie)
        CoreDataStack.share.save()
        
        return movie
        
    }
    
    func updateTask(movie: Movie, with title: String, hasWatched: Bool) {
        movie.title = title
        
        
        put(movie: movie)
        CoreDataStack.share.save()
    }
    
    func delete(movie: Movie) {
        CoreDataStack.share.mainContext.delete(movie)
        CoreDataStack.share.save()
    }
    var searchedMovies: [MovieRepresentation] = []
    
}
    
    
    
    
    // MARK: - Properties
    


