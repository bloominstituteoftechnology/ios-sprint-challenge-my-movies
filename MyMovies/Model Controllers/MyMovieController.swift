//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Joshua Sharp on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

protocol MyMovieDataDelegate {
    func updateMyMovie (myMovie: Movie, with title: String, hasWatched: Bool)
    func createMyMovie (with title: String, hasWatched: Bool)
}

class MyMovieController {
    
    static let shared = MyMovieController()
    
    init() {
        fetchFromServer()
    }
    
    func sync(completion: @escaping () -> Void = {}) {
        fetchFromServer()
        completion()
    }
    
    @discardableResult func create(with title: String, hasWatched: Bool = false) -> Movie {
        let myMovie = Movie(identifier: UUID(), title: title, hasWatched: hasWatched, context: CoreDataStack.shared.mainContext)
        CoreDataStack.shared.save()
        put(representation: myMovie.movieRepresentation)
        return myMovie
    }
    
    func update(myMovie: Movie, with title: String, hasWatched: Bool) {
        myMovie.title = title
        myMovie.hasWatched = hasWatched
        CoreDataStack.shared.save()
        put(representation: myMovie.movieRepresentation)
    }
    
    func delete(myMovie: Movie) {
        CoreDataStack.shared.mainContext.delete(myMovie)
        CoreDataStack.shared.save()
        //Implement delete from Firebase?
    }
    
    //MARK: - Firebase code
    
    func fbDelete (representation: MovieRepresentation, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        
    }
    
    func put(representation: MovieRepresentation?, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        guard let representation = representation,
        let identifier = representation.identifier?.uuidString else {
            NSLog("Task Representation is nil for put function.")
            completion(AppError.objectToRepFailed)
            return
        }
        let requestURL = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(representation)
            print ("HTTP Body: \(String(describing: request.httpBody))")
        } catch {
            NSLog("Error encoding task respresentation: \(error)")
            completion(error)
            return
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error PUTing myMovie: \(error)")
                completion(error)
                return
            }
            }.resume()
    }
    
    func fetchFromServer(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    print ("HTTP Response: \(response)")
                    completion(NetworkError.responseError)
                }
            }
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(NetworkError.responseError)
            }
            guard let data = data else {
                NSLog("No data returned from entries")
                completion(NetworkError.noData)
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let myMovieRepresentations =  try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value })
                self.updateEntries(with: myMovieRepresentations)
            } catch {
                NSLog("Error decoding: \(error)")
                completion(NetworkError.noDecode)
            }
            }.resume()
        completion(nil)
    }
    
    private func updateEntries(with representations: [MovieRepresentation]) {
        let identifiersToFetch = representations.compactMap({$0.identifier})
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var entriesToCreate = representationsByID
        let context = CoreDataStack.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        context.performAndWait {
            //Update Local store with Firebase
            do {
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                let existingEntries = try context.fetch(fetchRequest)
                for myMovie in existingEntries {
                    guard let identifier = myMovie.identifier,
                        let representation = representationsByID[identifier],
                        let hasWatched = representation.hasWatched else { continue }
                    
                        myMovie.title = representation.title
                        myMovie.hasWatched = hasWatched
                        entriesToCreate.removeValue(forKey: identifier)
                }
                NSLog("Creating \(entriesToCreate.count) entries from Firebase to local store.")
                for representation in entriesToCreate.values {
                    Movie(movieRepresentaion: representation, context: context)
                }
                CoreDataStack.shared.save(context: context)
            } catch {
                NSLog("Error fatching entries from persistent store: \(error)")
            }
            //Update Firebase with local only entries
            do {
                fetchRequest.predicate = NSPredicate(value: true)
                let allLocalEntries = try context.fetch(fetchRequest)
                let newLocalEntries = allLocalEntries.filter({!identifiersToFetch.contains($0.identifier!)})
                print ("New local entries to Firebase: \(newLocalEntries.count)")
                for myMovie in newLocalEntries {
                    put(representation: myMovie.movieRepresentation)
                }
            } catch {
                NSLog("Error putting new local entries to Firebase: \(error)")
            }
        }
    }
}


