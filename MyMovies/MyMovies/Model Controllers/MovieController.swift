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
	
	// MARK: - Properties
	
	var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let moviesBaseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
	private let collectionBaseURL = URL(string: "https://santana-movie-collection.firebaseio.com/")!
	
	//MARK: - CRUD
	
	func createMovie(for movie: MovieRepresentation) {
		CoreDataStack.shared.mainContext.performAndWait {
			guard let title = movie.title, let movieId = movie.id else { return }
			let newMovie = Movie(title: title, movieId: movieId)			
			
			do {
				try CoreDataStack.shared.save()
			} catch {
				NSLog("Error saving context when creating a new task")
			}
			putMovieInDB(newMovie)
		}
	}
	
	func update(movie: Movie) {
		CoreDataStack.shared.mainContext.performAndWait {
			do {
				try CoreDataStack.shared.save()
			} catch {
				NSLog("Error saving context when updating a new task")
			}
		}
		putMovieInDB(movie)
	}
	
	func delete(movie: Movie) {
		deleteMovieFromDB(movie)
		let moc = CoreDataStack.shared.mainContext
		
		moc.performAndWait {
			moc.delete(movie)
			do {
				try CoreDataStack.shared.save()
			} catch {
				NSLog("Error saving context when deleting a new task")
			}
		}
		
	}
}
	
//MARK: - MovieDB

extension MovieController {
	
    func searchForMovie(with searchTerm: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        var components = URLComponents(url: moviesBaseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(.failure(.other(error)))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(.success(true))
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(.failure(.notDecoding))
            }
        }.resume()
    }
}

//MARK: - Firebase

extension MovieController {
	
	func fetchCollection(completion: @escaping (Result<Bool, NetworkError>) -> Void) {
		let requestURL = collectionBaseURL.appendingPathExtension("json")
		
		URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
			if let error = error {
				if let response = response as? HTTPURLResponse, response.statusCode != 200 {
					NSLog("Error: status code is \(response.statusCode) instead of 200.")
				}
				NSLog("Error creating user: \(error)")
				completion(.failure(.other(error)))
				return
			}
			
			guard let data = data else {
				NSLog("No data was returned")
				completion(.failure(.noData))
				return
			}
			
			do {
				let decoder = JSONDecoder()
				
				let movieRepDictionary = try decoder.decode([String:MovieRepresentation].self, from: data)
				let movieReps = movieRepDictionary.map{$0.value}
				let context = CoreDataStack.shared.container.newBackgroundContext()
				
				self.updatePersistentStore(with: movieReps, context: context)
				completion(.success(true))
			} catch {
				completion(.failure(.notDecoding))
			}
			}.resume()
	}
	
	private func updatePersistentStore(with movieRepresentations: [MovieRepresentation], context: NSManagedObjectContext) {
		
		context.performAndWait {
			//See if the same id exists in CoreData
			for movieRep in movieRepresentations {
				guard let identifier = movieRep.identifier else { continue }
				let movie = self.movie(for: identifier, in: context)
				
				if let movie = movie {
					movie.title = movieRep.title
					movie.movieId = Double(movieRep.id ?? 0)
					movie.hasWatched = movieRep.hasWatched ?? false
				} else {
					_ = Movie(movieRepresentation: movieRep, context: context)
				}
			}
			
			do {
				try CoreDataStack.shared.save(context: context)
			} catch {
				NSLog("Error saving to core data")
				context.reset()
			}
		}
	}
	
	private func movie(for id: UUID, in context: NSManagedObjectContext) -> Movie? {
		let predicate  = NSPredicate(format: "id == %@", id as NSUUID)
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.predicate = predicate
		
		var movie: Movie?
		do {
			movie = try context.fetch(fetchRequest).first
		} catch {
			NSLog("Error fetching specific id")
		}
		return movie
	}
	
	func putMovieInDB(_ movie: Movie, completion: ((Result<Bool, NetworkError>) -> Void)? = nil) {
		var id = UUID()
		if let tempId = movie.identifier {
			id = tempId
		} else {
			#warning("update coredata movie without an id")
		}
		
		let requestURL = collectionBaseURL.appendingPathComponent(id.uuidString)
			.appendingPathExtension("json")
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.put.rawValue
		
		do {
			let movieData = try JSONEncoder().encode(movie.movieRepresentation)
			request.httpBody = movieData
		} catch {
			completion?(.failure(.notEncoding))
		}
		
		URLSession.shared.dataTask(with: request) { (_, _, error) in
			if let error = error {
				completion?(.failure(.other(error)))
			}
			completion?(.success(true))
			}.resume()
	}
	
	func deleteMovieFromDB(_ movie: Movie, completion: ((Result<Bool, NetworkError>) -> Void)? = nil) {
		guard let identifier = movie.identifier else {
			completion?(.failure(.noToken))
			return
		}
		
		let requestURL = collectionBaseURL.appendingPathComponent(identifier.uuidString)
			.appendingPathExtension("json")
		var request = URLRequest(url: requestURL)
		request.httpMethod = HTTPMethod.delete.rawValue
		
		URLSession.shared.dataTask(with: request) { (_, _, error) in
			if let error = error {
				completion?(.failure(.other(error)))
			}
			completion?(.success(true))
			}.resume()
	}
}
