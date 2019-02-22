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
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://movie-db-284b3.firebaseio.com/")!
    
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
    
    
    func createMovie(withName name: String, hasWatched: Bool) -> MovieRepresentation{
        let movie = MovieRepresentation(title: name)
        saveToPersistentStore()
        putMovie(movie)
        return movie
    }
    
    func updateMovie(movie: Movie, withTitle title: String, hasWatched: Bool){
        movie.title = title
        movie.hasWatched = hasWatched
        
        saveToPersistentStore()
    }
    
    
    func fetchTasksFromServer(completion: @escaping (Error?) -> Void = {_ in }) {
        
        let url = firebaseURL.appendingPathExtension("json")
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                
                let jsonDecoder = JSONDecoder()
                let movieRepresentations = try jsonDecoder.decode([String: MovieRepresentations].self, from: data)
                
                for(_, movieRep) in movieRepresentations {
                    let movieArray : [MovieRepresentation] = movieRep.results
                    for index in movieArray{
                        let newMovie = Movie(title: index.title, hasWatched: index.hasWatched ?? false)
                        newMovie.identifier = index.identifier
                        self.updateMovie(movie: newMovie, withTitle: index.title, hasWatched: index.hasWatched ?? false)
                    }
                }
                completion(nil)
            } catch {
                NSLog("\(error)")
                completion(error)
            }
            }.resume()
    }
    
    func putMovie(_ movie: MovieRepresentation, completion: @escaping (Error?) -> Void = {_ in}){
        let identifier = movie.identifier ?? UUID()
        let url = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let jsonEncoder = JSONEncoder()
        do{
            request.httpBody = try jsonEncoder.encode(movie)
        }catch{
            NSLog("Unable to encode task representation: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error{
                print(error)
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        do{
            try moc.save()
        }catch{
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    
    func checkMovie(for uuid: String) -> Movie?{
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        do{
            let moc = CoreDataStack.shared.mainContext
            return try moc.fetch(fetchRequest).first
        }catch{
            NSLog("Error fetching task with \(uuid): \(error)")
            return nil
        }
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
