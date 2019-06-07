//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Michael Flowers on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMovieController {
    static var shared = MyMovieController()
    private let baseURL = URL(string: "https://mymoviesprintchallenge.firebaseio.com/")!
    typealias completionHandler = (Error?) -> Void
    
    //MARK: Core Data CRUD functions
    
    func createMovie(title: String){
        let newMovie = Movie(title: title)
        put(movie: newMovie)
        saveToPersistentStore()
    }
    
    func delete(movie: Movie){
        CoreDataStack.shared.mainContext.delete(movie)
        deleteFromServer(movie: movie)
        saveToPersistentStore()
    }
    
    func toggle(movie: Movie){
        movie.hasWatched.toggle()
        put(movie: movie)
        saveToPersistentStore()
    }
    
    //MARK: FIREBASE CRUD
    
    func put(movie: Movie, completion: @escaping completionHandler = {_ in }){
        guard let identifier = movie.identifier?.uuidString else { print("Error unwrapping identifier"); completion(NSError()); return }
        let url = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        //turn movie into movieRep so that we can put it to the server
        guard let movieRepToServer = movie.movieRepresentation else { print("Error turning movie into movieRep"); completion(NSError()); return }
        let jE = JSONEncoder()
        
        do {
           request.httpBody = try jE.encode(movieRepToServer)
        } catch  {
            print("Error encoding movie into movieRep: \(error.localizedDescription)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse {
                print("This is the statusCode for Putting to the server: \(response.statusCode)")
            }
            if let error = error {
                print("Error putting movie to server: \(error.localizedDescription)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func deleteFromServer(movie: Movie, completion: @escaping completionHandler = {_ in }){
        guard let identifier = movie.identifier?.uuidString else { print("Error unwrapping identifier"); completion(NSError()); return }
        let url = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
     
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse {
                print("This is the statusCode for deleting a movieRep off of the server: \(response.statusCode)")
            }
            if let error = error {
                print("Error deleting off the server: \(error.localizedDescription)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func fetchFromServer(completion: @escaping completionHandler = {_ in }){
        let url = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("This is the statusCode for fetching all movieReps from the server: \(response.statusCode)")
            }
            if let error = error {
                print("Error fetching from the server: \(error.localizedDescription)")
                completion(error)
                return
            }
            guard let data = data else { print("Error unwrapping data fetching from server"); completion(NSError()); return }
            
            let jD = JSONDecoder()
            let backGroundContext = CoreDataStack.shared.container.newBackgroundContext()

            backGroundContext.performAndWait {
                do {
                    let movieRepDict = try jD.decode([ String : MovieRepresentation ].self, from: data)
                    let movieRepArray = Array(movieRepDict.values)
                    
                    //loop through the array of movieReps
                    for movieRep in movieRepArray {
                        //check to see if the movieRep is already saved in core data
                        if let movieInCoreData = self.checkMovieInCoreData(with: movieRep.title, context: backGroundContext ){
                            //movie is in core data and on server just update the movie in core data
                            self.update(movie: movieInCoreData, withMovieRep: movieRep)
                        } else {
                            //we have a movieRep on server but not in core data so we have to initialize a movie in core data with the values of the movieRep
                            _ = Movie(movieRepresentation: movieRep, context: backGroundContext)
                        }
                    }
                    try CoreDataStack.shared.save(context: backGroundContext)
                } catch {
                    print("Error decoding from server: \(error.localizedDescription)")
                    completion(error)
                    return
                }
            }
            completion(nil)
        }.resume()
    }
    
    func update(movie: Movie, withMovieRep: MovieRepresentation){
        movie.title = withMovieRep.title
        movie.hasWatched = withMovieRep.hasWatched!
    }
    
    func checkMovieInCoreData(with title: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        var movie: Movie? = nil
        do {
            //remember you want one, so we have to use the first property
           movie = try context.fetch(fetchRequest).first
        } catch  {
            print("Error checking movie in core data with title of movieRep: \(error.localizedDescription)")
            movie = nil
        }
        return movie
    }
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch  {
            print("Error saving to moc: \(error.localizedDescription)")
        }
    }
}

