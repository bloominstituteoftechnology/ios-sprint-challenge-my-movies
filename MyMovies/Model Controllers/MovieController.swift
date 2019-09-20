//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum HTTPMethod: String {
	case get = "GET"
	case put = "PUT"
	case post = "POST"
	case delete = "DELETE"
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
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
		
		func put(movie: Movie, completion: @escaping () -> Void = { }) {
			
			let identifier = movie.identifier ?? UUID()
			movie.identifier = identifier
			
			let requestURL = baseURL
				.appendingPathComponent(identifier.uuidString)
				.appendingPathComponent("json")
			
			var request = URLRequest(url: requestURL)
			request.httpMethod = HTTPMethod.put.rawValue
			
			guard let movieRepresentation = movie.movieReresentation else {
				NSLog("Movie Representation is nil")
				completion()
				return
			}
			
			do {
				request.httpBody = try JSONEncoder().encode(movieRepresentation)
			} catch {
				NSLog("Error encoding movie repersentation: \(error)")
				completion()
				return
			}
			
			URLSession.shared.dataTask(with: request) { (_, _, error) in
				if let error = error {
					NSLog("Error PUTing movie: \(error)")
					completion()
					return
				}
			}
		}
	
	func fetchTaskFromServer(completion: @escaping () -> Void = { }) {
		
		// appendingPathComponent adds a '/'
		// appendingPathExtension adds a '.'
		
		let requestURL = baseURL.appendingPathExtension("json")
		
		URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
			
			if let error = error {
				NSLog("Error fetching movie: \(error)")
				completion()
			}
			
			guard let data = data else {
				NSLog("No data returned from data movie")
				completion()
				return
			}
			
			do {
				let decoder = JSONDecoder()
				
				let movieRepresentations = try decoder.decode([String: MovieRepresentation].self, from: data).map({ $0.value })
				
				self.updateMovie(with: movieRepresentations)
				
			} catch {
				NSLog("Error decoding: \(error)")
			}
		}.resume()
	}
	
	func updateMovie(with representations: [MovieRepresentation]) {
		
		let identifiersToFetch = representations.compactMap({ $0.identifier })
		
		// [UUID: TaskRepresentation]
		
		let representationsById = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
		
		// Make a mutable copy of the dictionary above.
		var moviesToCreate = representationsById
		
		let context = CoreDataStack.shared.container.newBackgroundContext()
		
		context.performAndWait {
			
			do {
				//				let context = CoreDataStack.shared.mainContext
				
				let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
				
				// identifier == \(identifier)
				fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
				
				// Which of these tasks exsist in Core Data already?
				let exsistingMovie = try context.fetch(fetchRequest)
				
				// Which need to be updated? Which need to be put into Core Data?
				for movie in exsistingMovie {
					guard let identifier = movie.identifier,
						// This gets the task representation that corresponds to the task from Core Data.
						let representation = representationsById[identifier] else { continue }
					
					movie.title = representation.title
					movie.hasWatched = representation.hasWatched ?? false
					
					moviesToCreate.removeValue(forKey: identifier)
				}
				
				// Take the task that AREN'T in Core Data and create new ones for them.
				for represntation in moviesToCreate.values {
					Movie(movieRepresentation: represntation, context: context)
				}
				
				CoreDataStack.shared.save(context: context)
				
			} catch {
				NSLog("Error fetching task from persistent store: \(error)")
			}
		}
	}
	
	func addMovie(movie: MovieRepresentation) {
		let addedMovie = Movie()
		
		CoreDataStack.shared.save()
		
		put(movie: addedMovie)
		
	}
	
	func updateTheMovie(movie: Movie) {
		
		CoreDataStack.shared.save()
		put(movie: movie)
		
	}
	
	func delete(movie: Movie) {
		let theMovie = Movie()
		CoreDataStack.shared.mainContext.delete(movie)
		CoreDataStack.shared.save()
	}
	
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
