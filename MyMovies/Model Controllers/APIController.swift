//
//  APIController.swift
//  MyMovies
//
//  Created by Joe Thunder on 12/29/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
    case post = "POST"
}

class APIController {
    
    let baseURL = URL(string: "https://movie-d88b6.firebaseio.com/mymovies/V53PSP7l452vDX6kyzYg")!
    
    // using init as "viewDidLoad"
    init() {
         fetchMyMoviesFromFirebase()
    }
    
    // fetch tasks from Firebase
    func fetchMyMoviesFromFirebase(completion: @escaping () -> Void = { }) {

        let requestURL = baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL)  { (data, _, error)  in
            if let error = error {
                NSLog("Error with URL Request. \(error)")
                completion()
                return
            }
            guard let data = data else {
                NSLog("Error with returning data.")
                completion()
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let movies = Array(try decoder.decode([String : MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movies)
            } catch {
                
            }
        }.resume()
    }
    

    func updateMovies(with representations: [MovieRepresentation]) throws {
          let entriesWithID = representations.filter({ $0.identifier != nil })
          let identifiersToFetch = entriesWithID.compactMap({ $0.identifier! })
          
          let representationByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, entriesWithID))
          
          var entriesToCreate = representationByID
          
          let fetchRequest: NSFetchRequest<Movies> = Movies.fetchRequest()
          fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
          
          let context = CoreDataStack.shared.container.newBackgroundContext()
          
          context.perform {
              do {
              let existingEntries = try context.fetch(fetchRequest)
              for entry in existingEntries {
                  guard let id = entry.identifier,
                      let representation = representationByID[id] else {
                          context.delete(entry)
                          continue
                  }
                  entry.title = representation.title
                entry.hasWatched = representation.hasWatched ?? false
                  entriesToCreate.removeValue(forKey: id)
              }
              for representation in entriesToCreate.values {
                  Movies(movieRepresentation: representation, context: context)
              }
              } catch {
                  print("Error fetching tasks for UUIDs: \(error)")
              }
          }
            //Persist all changes to Core Data
          try CoreDataStack.shared.save(context: context)
      }
    
    //PUT
    func putMovies(movie: Movies, completion: @escaping () -> Void = { }) {
        let identifier =  movie.identifier ?? UUID().uuidString
        movie.identifier = identifier
        
        let requestURL = baseURL
            .appendingPathComponent(identifier)
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
            NSLog("Error encoding task representation: \(error)")
            completion()
            return
        }
        
    }
}
