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
    
    //MARK: - Variables
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://moviesprintchallenge.firebaseio.com/")
    
    //MARK: - Computed Properties
    //Fetching All Movies
    var movies: [Movie] {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let context = CoreDataStack.shared.mainContext
        do {
            return try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
    
    //Searching For Movies
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
    
    //Send Movie Data in json format to the Firebase Server using the firbaseURL
    func sendToServer(movie: Movie, completion: @escaping () -> Void) {
        
        //UnWrapping
        guard let identifier = movie.identifier, let title = movie.title else {
            completion()
            return
        }
        
        //Creating Representation
        let movieRepresentation = MovieRepresentation(title: title, identifier: identifier, hasWatched: movie.hasWatched)
        
        //Request URL
        let requestURL = firebaseURL?.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        guard let tempRequestURL = requestURL else {
            completion()
            return
        }
        
        var request = URLRequest(url: tempRequestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
        } catch {
            print("Error encoding in SendToServer: \(error)")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error sending task to server: \(error)")
                completion()
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Bad Response when fetching")
                completion()
                return
            }
            completion()
        }.resume()
    }
    
    //Deletes a movie from the Firebase Server
    func deleteMovieFromServer(movie: Movie, completion: @escaping () -> Void) {
        
        //Unwrapping
        guard let identifier = movie.identifier else {
            print("Bad ID in delete function")
            completion()
            return
        }
        
        //Extending the URL
        guard let tempFirebaseURL = firebaseURL else {
            print("Bad URL in delete function")
            completion()
            return
        }
        let requestURL = tempFirebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        print("Deleting Item From Server")
        
        //Sending Data to URLSession
        URLSession.shared.dataTask(with: request) { (data, response, error) in
           
            //Error Checking
            if let error = error {
                print("Error deleting entity: \(error)")
                completion()
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Bad Response when fetching")
                completion()
                return
            }
            
            completion()
        }.resume()
        
    }
    
    //Fetch movies from the Firebase Server
    func fetchMoviesFromServer(completion: @escaping () -> Void) {
        
        //Create Request URL
        let requestURL = firebaseURL?.appendingPathExtension("json")
        
        //Unwrapping
        guard let tempRequestURL = requestURL else {
            print("Bad URL in FetchFromServer")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: tempRequestURL) { (data, response, error) in
            //Error Checking
            if let error = error {
                print("Error fetching: \(error)")
                completion()
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Bad Response when fetching")
                completion()
                return
            }
            
            guard let data = data else {
                print("Bad Data when fetching")
                completion()
                return
            }
            
            do {
                //Getting back Data and returning it as an array of MovieRepresentation Objects
                let movieRepresentation = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                try self.updateMovie(representation: movieRepresentation)
                completion()
            } catch {
                print("Error decoding entity when fetching: \(error)")
                completion()
            }
        }
    }
    
    //Updating Movies
    func updateMovie(representation: [MovieRepresentation]) {
        
    }
    
    // MARK: - Properties
    var searchedMovies: [MovieRepresentation] = []
}
