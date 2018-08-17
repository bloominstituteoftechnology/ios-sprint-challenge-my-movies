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
    
    // MARK: - Initializer
    init() {
        fetchEntriesFromServer()
    }
    
    
    // MARK: - Typealias
    typealias CompletionHandler = (Error?) -> Void
    
    // MARK: - Properties
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://coredatamovie.firebaseio.com/")!
    
    // MARK: - Methods
    
    //Put to firebase
    func put(entry: Entry, completion: @escaping CompletionHandler = {_ in}) {
        
        let uuid = entry.identifier?.uuidString ?? UUID().uuidString
        let requestURL = firebaseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(entry)
        } catch {
            NSLog("Error encoding entry: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _ , error) in
            if let error = error {
                NSLog("Error encoding data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    //Create New Entry On Firebase and Save to Persistent Store
    func create(title: String) {
        let entry = Entry(title: title)
        put(entry: entry)
        saveToPersistentStore()
    }
    
    //Saves to Persistent Store
    func saveToPersistentStore() {
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    
    
    //Search for Movies from The Movie DB
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
    
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = {_ in}) {
        
        let request = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: request) { (data, _ , error) in
            if let error = error {
                NSLog("Error fetching movies: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("Error getting data from server")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values)
                let backgroundMOC = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateMovie(with: movieRepresentations, context: backgroundMOC)
                completion(nil)
                return
            } catch {
                NSLog("Error decoding task representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    func updateMovie(with representation: [MovieRepresentation], context: NSManagedObjectContext) throws {
        var error: Error?
        
        context.performAndWait{
            for movieRep in representation {
                guard let uuid = UUID(uuidString: (movieRep.identifier?.uuidString)!) else {continue}
                let movie = self.fetchSingleEntryFromPersistentStore(forUUID: uuid, context: context)
                if let movie = movie {
                    self.update(entry: movie, movieRep: movieRep)
                } else {
                    let _ = Entry(movieRepresentation: movieRep, context: context)
                }
            }
            
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error {throw error}
    }
    
    func fetchSingleEntryFromPersistentStore(forUUID: UUID, context: NSManagedObjectContext) -> Entry? {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forUUID as NSUUID)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching task with identifier: \(error)")
            return nil
        }
    }
    
    func update(entry: Entry, movieRep: MovieRepresentation ) {
        entry.title = movieRep.title
        entry.hasWatched = movieRep.hasWatched!
        entry.identifier = movieRep.identifier
    }
    
    
    func deleteEntryFromServer(entry: Entry, completion: @escaping CompletionHandler = {_ in}) {
        let uuid = entry.identifier?.uuidString ?? UUID().uuidString
        let requestURL = firebaseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error encoding data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func delete(entry: Entry) {
        deleteEntryFromServer(entry: entry)
        let moc = CoreDataStack.shared.mainContext
        moc.delete(entry)
        saveToPersistentStore()
    }
    
    func update(movie: Entry, hasWatched: Bool) {
        movie.hasWatched = hasWatched
        saveToPersistentStore()
    }
    
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
