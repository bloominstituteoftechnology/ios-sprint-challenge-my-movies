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
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let fireBaseURL = URL(string: "https://lambda-mymovie-challenge.firebaseio.com/")!
    let mainContext = CoreDataStack.shared.mainContext
    typealias CompletionHandler = (Error?) -> ()
    
    //MARK: Init
    init() {
        fetchEntriesFromServer()
    }
        
    //MARK: Read
    func fetchEntriesFromServer(complete: @escaping CompletionHandler = {_ in}) {
        let url = fireBaseURL.appendingPathExtension("json")
        guard let request = NetworkService.createRequest(url: url, method: .get) else {
            complete(NSError(domain: "bad request", code: 400, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                complete(error)
                return
            }
            guard let data = data else {
                let error = NSError(domain: "MovieController.fetchEntriesFromServer.request.httpBody.NODATA", code: 0, userInfo: nil)
                print(error)
                complete(error)
                return
            }
            guard let optionalMovieReps = NetworkService.decode(to: [String: MovieRepresentation].self, data: data) else {
                let error = NSError(domain: "MovieController.fetchEntriesFromServer.DECODE_ERROR", code: 0, userInfo: nil)
                print(error)
                complete(error)
                return
            }
            var movieReps = [MovieRepresentation]()
            for (id, representation) in optionalMovieReps {
                var rep = representation
                rep.identifier = UUID(uuidString: id)
                movieReps.append(rep)
            }
            self.updateMovies(with: movieReps)
            complete(nil)
        }.resume()
    }
    
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
            let context = CoreDataStack.shared.backgroundContext
            context.performAndWait {
                do {
                    //decode data into movieReps
                    let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                    
                    //get array of titles for searching in CoreData
                    let searchedMovieTitles = movieRepresentations.compactMap{$0.title}
                    //create fetchRequest and assign predicate as searched titles
                    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "title IN %@", searchedMovieTitles)
                    //create array of matching movies to be removed from result
                    let savedMoviesInSearch = try context.fetch(fetchRequest)
                    //create array of matching movie reps
                    var savedMovieRepArray = [MovieRepresentation]()
                    for movie in savedMoviesInSearch {
                        guard var rep = movie.movieRepresentation else {return}
                        rep.identifier = nil
                        rep.hasWatched = nil
                        savedMovieRepArray.append(rep)
                    }
                    
                    //only display movies that aren't already in the list
                    self.searchedMovies = movieRepresentations.filter{!savedMovieRepArray.contains($0)}
                    context.reset()
                    completion(nil)
                } catch {
                    NSLog("Error decoding JSON data: \(error)")
                    completion(error)
                }
            }
            
        }.resume()
    }
    
    //MARK: Update/Create
    //PUT method does both in the case of Firebase when we want a custom identifier
    
    func updateMovies(with reps: [MovieRepresentation]) {
        //create fetchRequest
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        //create array of identifiers from array of movieReps
        let identifiers = reps.compactMap { $0.identifier }
        //only fetch identifiers passed in
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        //create dictionary of movies to be updated. Type is [UUID:MovieRepresentation] (this matches the remote database format)
        var repDict = Dictionary(uniqueKeysWithValues: zip(identifiers, reps))
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                //fetch movies as outlined above
                let movies = try context.fetch(fetchRequest)
                for movie in movies {
                    //get the specific movie to update
                    guard let id = movie.identifier,
                        let representation = repDict[id]
                    else {continue}
                    //update the movie
                    self.updateMovie(movie: movie, movieRep: representation)
                    //remove from the dictionaries of movies to be updated
                    repDict.removeValue(forKey: id)
                }
                for rep in repDict.values {
                    Movie(movieRepresentation: rep, context: context)
                }
                CoreDataStack.shared.save(context: context)
            } catch {
                print(error)
            }
        }
        
    }
    
    func updateMovie(movie: Movie, movieRep: MovieRepresentation) {
        let hasWatched = movieRep.hasWatched
        movie.title = movieRep.title
        movie.hasWatched = hasWatched ?? false
        put(movie: movie)
    }
    
    func put(movie: Movie, complete: @escaping CompletionHandler = {_ in }) {
        
        //construct representation of Movie for firebase server
        guard let rep = movie.movieRepresentation else {
            complete(NSError(domain: "MovieRepresentationConversion", code: 1))
            return
        }
        
        let id = movie.identifier ?? UUID()
        let postURL = fireBaseURL.appendingPathComponent(id.uuidString).appendingPathExtension("json")
        guard let request = NetworkService.createRequest(url: postURL, method: .put, headerType: .contentType, headerValue: .json) else {
            complete(NSError(domain: "PutRequestError", code: 400, userInfo: nil))
            return
        }
        
        //encode
        let encodingStatus = NetworkService.encode(from: rep, request: request)
        if let error = encodingStatus.error {
            print("error encoding: \(error)")
            complete(error)
            return
        } else {
            guard let encodingRequest = encodingStatus.request else {return}
            URLSession.shared.dataTask(with: encodingRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                    print("Bad response code \(response.statusCode)")
                    complete(NSError(domain: "APIStatusNotOK", code: response.statusCode, userInfo: nil))
                    return
                }
                if let error = error {
                    complete(error)
                    return
                }
                complete(nil)
            }.resume()
        }
    }
    
    //MARK: Delete
    func deleteMovieFromServer(movie: Movie, complete: @escaping CompletionHandler = { _ in }) {
        
        let url = fireBaseURL.appendingPathComponent(movie.identifier!.uuidString).appendingPathExtension("json")
        print(url)
        guard let request = NetworkService.createRequest(url: url, method: .delete) else {
            complete(NSError(domain: "badRequest", code: 400, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _,response,error in
            if let error = error {
                print("error deleting movie: \(error)")
                complete(error)
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                   print("Bad response code")
                   complete(NSError(domain: "APIStatusNotOK", code: response.statusCode, userInfo: nil))
                   return
                } else {
                    complete(nil)
                }
            } else {
                let error = NSError(domain: "no response from endpoint in MovieController.deleteMovieFromServer", code: 000, userInfo: nil)
                print(error)
                complete(error)
            }
        }.resume()
    }
    
    func deleteMovie(movie: Movie, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        deleteMovieFromServer(movie: movie) { error in
            if error != nil {
                print(error as Any)
            }
        }
        context.perform {
            context.delete(movie)
            CoreDataStack.shared.save(context: context)
        }
    }
    
    
    
}
