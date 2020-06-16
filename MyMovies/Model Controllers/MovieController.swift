//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

typealias CompletionHandler = (String?) -> Void
let EmptyHandler:CompletionHandler = {_ in}

class MovieController {
    
    static var shared = MovieController()
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    var searchedMovies: [MovieRepresentation] = []
    
    lazy var fetcher:NSFetchedResultsController<Movie> = {
        let moc = CoreDataStack.shared.mainContext
        var req:NSFetchRequest<Movie> = Movie.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true),
                               NSSortDescriptor(key:"title", ascending:true)]

        var frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: moc,
            sectionNameKeyPath: "hasWatched",
            cacheName: nil)

        do {
            try frc.performFetch()
        } catch {
            NSLog("Error fetching data from local store: \(error)")
        }

        return frc
    }()

    func create(_ title:String, doPut:Bool = true, doSave:Bool=true, moc:NSManagedObjectContext = CoreDataStack.shared.mainContext)
    {
        moc.perform {
            let movie = Movie(title, moc:moc)
            if doPut {
                self.put(movie)
            }
            if doSave {
                do {
                    try moc.save()
                } catch {
                    NSLog("Failed to save while creating a new movie")
                }
            }
        }
    }

    func containsMovieWithTitle(_ title:String, moc:NSManagedObjectContext=CoreDataStack.shared.mainContext) -> Bool
    {
        var result = false
        moc.performAndWait {
            let req:NSFetchRequest<Movie> = Movie.fetchRequest()
            req.predicate = NSPredicate(format: "title = %@", title)
            var movie: Movie?
            do {
                movie = try moc.fetch(req).first
            } catch {
                logError(EmptyHandler, "Error searching")
            }
            result = movie != nil
        }
        return result
    }

    func addOrUpdateFromStub(_ representation: MovieRepresentation, moc:NSManagedObjectContext) throws
    {
        var caughtError:Error?
        moc.perform {
            let req:NSFetchRequest<Movie> = Movie.fetchRequest()
            req.predicate = NSPredicate(format: "identifier = %@", representation.identifier! as NSUUID)
            var movie: Movie?
            do {
                movie = try moc.fetch(req).first
            } catch {
                caughtError = error
            }

            if let movie = movie {
                movie.apply(representation)
            } else {
                _ = Movie(representation.title, representation.hasWatched ?? false, representation.identifier, moc:moc)
            }
        }

        if let caughtError = caughtError {
            throw caughtError
        }
    }

    func toggleWatched(_ movie: Movie, doPut:Bool = true, doSave:Bool = true)
    {
        movie.managedObjectContext!.performAndWait {
            movie.hasWatched = !movie.hasWatched
            if doPut {
                self.put(movie)
            }
            if doSave {
                do {
                    try movie.managedObjectContext?.save()
                } catch {
                    NSLog("Failed to save while creating a new movie")
                }
            }
        }
    }

    func delete(_ movie: Movie, _ completion:@escaping CompletionHandler = EmptyHandler)
    {
        let stub = movie.getStub()
        guard let moc = movie.managedObjectContext else { return }
        moc.performAndWait {
            moc.delete(movie)
            do {
                try moc.save()
            } catch {
                self.logError(completion, "Unable to save moc")
                return
            }
        }

        let req = buildRequest([stub.identifier!.uuidString], "DELETE")
        URLSession.shared.dataTask(with: req) { (_, _, error) in
            if let error = error {
                self.logError(completion, "Error deleting: \(error)")
                return
            }

            completion(nil)

        }.resume()
    }

    func put(_ movie: Movie, _ completion:@escaping CompletionHandler = EmptyHandler)
    {
        var data:Data?
        do {
            data = try JSONEncoder().encode(movie.getStub())
        } catch {
            logError(completion, "Failed to encode movie: \(error)")
        }

        let req = buildRequest([movie.identifier!.uuidString], "PUT", data)
        URLSession.shared.dataTask(with: req) { (_, _, error) in
            if let error = error {
                self.logError(completion, "Error putting: \(error)")
                return
            }
            completion(nil)
        }.resume()
    }

    func fetchRemote(_ completion:@escaping CompletionHandler = EmptyHandler)
    {
        let moc = CoreDataStack.shared.container.newBackgroundContext()
        let req = buildRequest([], "GET")
        URLSession.shared.dataTask(with: req) { data, _, error in
            if let error = error {
                self.logError(completion, "Error fetching: \(error)")
            }

            guard let data = data else { self.logError(completion, "Fetching: data was nil"); return}

            do {
                let stubs = try JSONDecoder().decode([String: MovieRepresentation].self, from:data)
                for (_, stub) in stubs {
                    try self.addOrUpdateFromStub(stub, moc: moc)
                }
                try CoreDataStack.save(moc:moc)
                completion(nil)
            } catch {
                self.logError(completion, "Fetching: failed to decode and save data: \(error)")
            }
        }.resume()
    }


    func buildRequest(_ ids:[String], _ httpMethod:String, _ data:Data?=nil) -> URLRequest
    {
        var url = baseURL
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
    
    // MARK: - Properties
    
//    var searchedMovies: [MovieRepresentation] = []
    
    func logError(_ completion:@escaping CompletionHandler, _ error:String)
    {
        NSLog(error)
        completion(error)
    }
}
