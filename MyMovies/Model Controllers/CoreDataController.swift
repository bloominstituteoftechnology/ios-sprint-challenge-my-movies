//
//  CoreDataController.swift
//  MyMovies
//
//  Created by Austin Potts on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String{
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}


class CoreDataController {
    
    init(){
        fetchMovieFromServer()
    }
    
    let baseURL = URL(string: "https://movies-f2bd9.firebaseio.com/")!
    
    
    func put(movie: Movie, completion: @escaping()-> Void = {}) {
        
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
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
        
        
        
        let requestURL = baseURL.appendingPathExtension("json")
        
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
    
    
}
