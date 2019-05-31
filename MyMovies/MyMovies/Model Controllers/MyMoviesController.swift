//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesController {
	
	func put(movie: Movie, completion: @escaping (Error?) -> ()) {
		let identifier = movie.identifier ?? UUID()
		let requestUrl = baseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
		
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "PUT"
		
		do {
			guard let movieRep = movie.movieRepresentation else {
				completion(NSError())
				return
			}
			request.httpBody = try JSONEncoder().encode(movieRep)
		} catch {
			print("Error encoding to movide: \(error) ")
			completion(error)
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let response = response as? HTTPURLResponse {
				print("Fetching movies from firebase response: \(response.statusCode)")
			}
			
			if let error = error {
				NSLog("Error fetching movies: \(error)")
				completion(error)
				return
			}
			CoreDataStack.shared.mainContext.performAndWait {
				movie.identifier = identifier
			}
			
			try? CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
			completion(nil)
		}.resume()
		
	}
	
	func deleteMovieFromServer(movie: Movie, completion: @escaping (Error?) -> ()) {
		let identifier = movie.identifier ?? UUID()
		let requestUrl = baseUrl.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
		
		var request = URLRequest(url: requestUrl)
		request.httpMethod = "DELETE"
		
		do {
			guard let movieRep = movie.movieRepresentation else {
				completion(NSError())
				return
			}
			request.httpBody = try JSONEncoder().encode(movieRep)
		} catch {
			print("Error encoding to movide: \(error) ")
			completion(error)
			return
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let response = response as? HTTPURLResponse {
				print("Fetching movies from firebase response: \(response.statusCode)")
			}
			
			if let error = error {
				NSLog("Error fetching movies: \(error)")
				completion(error)
				return
			}
			CoreDataStack.shared.mainContext.performAndWait {
				movie.identifier = identifier
			}
			
			try? CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
			completion(nil)
			}.resume()
	}
	
	
	func fetchMoviesFromServer(completion: @escaping (Error?) -> ()) {
		
		let url = baseUrl.appendingPathExtension("json")
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let response = response as? HTTPURLResponse {
				print("Fetching movies from firebase response: \(response.statusCode)")
			}
			
			if let error = error {
				NSLog("Error fetching movies: \(error)")
				completion(error)
				return
			}
			
			guard let data = data else {
				NSLog("error fetching data from firebase")
				completion(NSError())
				return
			}
			
			print(data)
			
			do {
				let result = try JSONDecoder().decode([String: MovieRepresentation].self, from: data)
				let movieReps = Array(result.values)
				try self.updateMovies(with: movieReps)
				completion(nil)
			} catch {
				print("Error decoding movies from firebase: \(error)")
			}
			
		}.resume()
	}
	
	let baseUrl = URL(string: "https://movies-c2ab5.firebaseio.com/")!
}

extension MyMoviesController {
	
	private func updateMovies(with movieReps: [MovieRepresentation]) throws {
		
		let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
		
		backgroundContext.performAndWait {
			for movieRep in movieReps {
				updateMovie(movieRep: movieRep, context: backgroundContext)
			}
		}
		
		try CoreDataStack.shared.save(context: backgroundContext)
	}
	
	private func updateMovie(movieRep: MovieRepresentation, context: NSManagedObjectContext) {
		guard let identifier = movieRep.identifier,
			let hasWatched = movieRep.hasWatched else { return }
		
		CoreDataStack.shared.mainContext.performAndWait {
			
			if let movie = fetchSingleMovieFromPersistentStore(forUUID: identifier, context: context) {
				movie.title = movieRep.title
				movie.hasWatched = hasWatched
				movie.identifier = identifier
			} else {
				let _ = Movie(title: movieRep.title)
			}
		}
		
	}
	
	private func fetchSingleMovieFromPersistentStore(forUUID uuid: UUID, context: NSManagedObjectContext) -> Movie? {
		
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
		
		var result: Movie? = nil
		
		context.performAndWait {
			do {
				result = try context.fetch(fetchRequest).first
			} catch {
				NSLog("Error fetching movie with predicate: \(error)")
			}
		}
		
		return result
	}
}

