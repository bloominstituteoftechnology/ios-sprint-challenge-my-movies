//
//  FirebaseController.swift
//  MyMovies
//
//  Created by Lotanna Igwe-Odunze on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FirebaseController {
    
    //Firebase
    private let firebaseURL = URL(string: "https://sprint-4-challenge.firebaseio.com/")!
    
    //Put new movie on FB
    func sendMovie(movie:Movie, _ completion: @escaping Completions = Empties)
    {
        var data:Data?
        do {
            data = try JSONEncoder().encode(movie.getMovie())
        } catch {
            
            showErrors(completion, "Couldn't encode movie: \(error)")
        }
        
        let req = buildRequest([movie.identifier!.uuidString], "PUT", data)
        URLSession.shared.dataTask(with: req) { (_, _, error) in
            if let error = error {
                self.showErrors(completion, "Error putting: \(error)")
                return
            }
            completion(nil)
            }.resume()
    }
    
    //Retrieve movie from FB
    func getMovieOnFB(_ completion:@escaping Completions = Empties)
    {
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        let req = buildRequest([], "GET")
        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error {
                self.showErrors(completion, "Error fetching: \(error)")
            }
            
            guard let data = data else { self.showErrors(completion, "Couldn't fetch data."); return}
            
            do {
                let stubs = try JSONDecoder().decode([String: MovieRepresentation].self, from:data)
                for (_, stub) in stubs {
                    try CoreDataController().referToMovieRep(movieRep: stub, moc: moc)
                }
                try CoreDataStack.saveAfterMerging(moc:moc)
                completion(nil)
            } catch {
                self.showErrors(completion, "Couldn't decode data: \(error)")
            }
            }.resume()
    }
    
    
    
    
    
    
    
    func buildRequest(_ ids:[String], _ httpMethod:String, _ data:Data?=nil) -> URLRequest
    {
        var url = firebaseURL
        url.appendPathComponent("movies")
        for id in ids {
            url.appendPathComponent(id)
        }
        url.appendPathExtension("json")
        var req = URLRequest(url: url)
        req.httpMethod = httpMethod
        req.httpBody = data
        return req
    }
    
    //Report Errors
    func showErrors(_ completion: @escaping Completions, _ error: String)
    {
        NSLog(error)
        completion(error)
    }
}

//Type Alias for pretty completion handling
typealias Completions = (String?) -> Void
let Empties: Completions = {_ in}
