//
//  myMovieController.swift
//  MyMovies
//
//  Created by Michael Flowers on 10/12/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMovieController {
    static var shared = MyMovieController()
    private let baseURL = URL(string: "https://mymoviesprintchallenge.firebaseio.com/")!
    typealias completionHandler = (Error?) -> Void
    
    init(){
        fetchFromServer()
    }
    
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
        //make sure that the movie passed in has an identifier, if it doesn't give it one
        guard let identifier = movie.identifier?.uuidString else { print("Error finding identifier");
            completion(NSError()); return }
        
        //append the identifier to the base url and then extend the json
        let url = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: url)
        
        //now that we have the request we can construct the method and put data in its body
        request.httpMethod = "PUT"
        
        //turn the movie that was passed into the function into a movieRep (basically removing the context property) so that we can put it to the server
        guard let movieRepToServer = movie.movieRepresentation else { print("Error turning movie into movieRep"); completion(NSError()); return }
        let jE = JSONEncoder()
        
        do {
            //Try to encode the movieRep object and put the data into the request httpBody
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
        guard let identifier = movie.identifier?.uuidString else { print("Error movie doesn't have an identifier"); completion(NSError()); return }
        //append the identifier so that we get the right movie to delete
        let url = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: url)
        //because this is a delete method we don't need to put any data into the httpBody
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
            
            //Because we are doing this inside of a URLSession DataTask, which happens on a background thread, we need to make sure that anything thing we do with core data happens on that same thread. Also because we are handling core data objects, we need to do that on the background thread in a performAndWait block.
            
            
            //create a backGroundContext in on our Container (not moc)
            let backGroundContext = CoreDataStack.shared.container.newBackgroundContext()

            backGroundContext.performAndWait {
                do {
                    //remember json/firebase is a dictionary of string: Any, but Any for me is our model
                    let movieRepDict = try jD.decode([ String : MovieRepresentation ].self, from: data)
                    
                    //put those values of the dictionaries in an array
                    let movieRepArray = Array(movieRepDict.values)
                    
                    //loop through the array of movieReps
                    for movieRep in movieRepArray {
                        //check to see if the movieRep is already saved in core data -REMEMBER This has to happen on a background context because this is in a function thats being called on a background thread
                        if let movieInCoreData = self.checkMovieInCoreData(with: movieRep.title, context: backGroundContext ){
                            
                            //movie is in core data and on server, so just update the movie in core data
                            self.update(movie: movieInCoreData, withMovieRep: movieRep)
                        } else {
                            //we have a movieRep on server but not in core data so we have to initialize a movie in core data with the values of the movieRep
                            //REMEMBER This has to happen on a background context because this is in a function thats being called on a background thread
                            _ = Movie(movieRepresentation: movieRep, context: backGroundContext)
                        }
                    }
                    //REMEMBER This has to happen on a background context because this is in a function thats being called on a background thread
                    //create a new save function in coredatastack that will save this on a backgroundContext
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
    
    //This function will check whats in core data and see if one matches it on the server. NOTE: make a context parameter so we can check this on both the main or background context/thread
    func checkMovieInCoreData(with title: String, context: NSManagedObjectContext) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        //use the title we pass in as a parameter to search through coreData as a predicate
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
