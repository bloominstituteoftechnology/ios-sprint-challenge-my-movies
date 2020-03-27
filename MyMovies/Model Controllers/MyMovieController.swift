//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Wyatt Harrell on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class MyMovieController {
    
    typealias CompletionHandler = (Error?) -> Void
    let baseURL = URL(string: "https://movies-c9611.firebaseio.com/")!
    
    func sendMovieToServer(movie: Movie, completeion: @escaping CompletionHandler = { _ in }) {
        let uuid = movie.identifier!
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = movie.movieRepresentation else {
                completeion(NSError())
                return
            }
            
            try CoreDataStack.shared.mainContext.save()
            #warning("Migrate saving")
            request.httpBody = try JSONEncoder().encode(representation)
            
        } catch {
            NSLog("Error encoding/saving movie: \(error)")
            completeion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTing movie to server: \(error)")
                completeion(error)
                return
            }
            
            completeion(nil)
        }.resume()
        
        
        
        
    }
    
    
    
    
    
    
    
}
