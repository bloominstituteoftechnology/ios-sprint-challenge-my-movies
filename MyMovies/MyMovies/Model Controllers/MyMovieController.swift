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
        _ = Movie(title: title)
        saveToPersistentStore()
    }
    
    func delete(movie: Movie){
        CoreDataStack.shared.mainContext.delete(movie)
        saveToPersistentStore()
    }
    
    func toggle(movie: Movie){
        movie.hasWatched.toggle()
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
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        do {
            try moc.save()
        } catch  {
            print("Error saving to moc: \(error.localizedDescription)")
        }
    }
}

