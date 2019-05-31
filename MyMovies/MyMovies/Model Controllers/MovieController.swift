//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


protocol MovieControllerProtocol: AnyObject {
	var movieController: MovieController? { get set }
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!

	init() {
		remoteFetchAll { (result: Result<[MovieRepresentation], NetworkError>) in
			do {
				_ = try result.get()
			} catch {
				NSLog("error fetching: \(error)")
			}
		}
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
    
    var searchedMovies: [MovieRepresentation] = []

	private let firebaseURL = URL(string: "https://lambda-school-mredig.firebaseio.com/myMovies")!
	let networkHandler = NetworkHandler()
}



// MARK: - CoreData and Firebase stuff
extension MovieController {

	func remotePut(movie: Movie, completion: @escaping (Result<MovieRepresentation, NetworkError>) -> Void = { _ in }) {
		let identifier = movie.threadSafeID ?? UUID()
		let putURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
		movie.threadSafeID = identifier

		var request = URLRequest(url: putURL)
		request.httpMethod = HTTPMethods.put.rawValue

		guard let movieRep = movie.movieRepresentation else {
			completion(.failure(.otherError(error: NSError())))
			return
		}

		let encoder = JSONEncoder()
		do {
			request.httpBody = try encoder.encode(movieRep)
		} catch {
			completion(.failure(.dataCodingError(specifically: error)))
			return
		}

		networkHandler.transferMahCodableDatas(with: request, completion: completion)
	}

	func remoteDelete(movie: Movie, completion: @escaping (Result<Data?, NetworkError>) -> Void = { _ in }) {
		let identifier = movie.threadSafeID ?? UUID()
		let deleteURL = firebaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
		movie.threadSafeID = identifier

		var request = deleteURL.request
		request.httpMethod = HTTPMethods.delete.rawValue

		networkHandler.transferMahOptionalDatas(with: request, completion: completion)
	}

	func remoteFetchAll(completion: @escaping (Result<[MovieRepresentation], NetworkError>) -> Void = { _ in }) {
		let getURL = firebaseURL.appendingPathExtension("json")

		let request = getURL.request

		networkHandler.transferMahCodableDatas(with: request) { [weak self] (result: Result<[String: MovieRepresentation], NetworkError>) in
			do {
				let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
				let movieDict = try result.get()
				let movieArray = Array(movieDict.values)

				backgroundContext.performAndWait {
					for movieRep in movieArray {
						guard let identifier = movieRep.identifier else { continue }
						if let movie = self?.get(movieWithUUID: identifier, fromContext: backgroundContext) {
							if movie != movieRep {
								self?.update(watched: movieRep.hasWatched ?? false, onMovie: movie, onContext: backgroundContext)
							}
						} else {
							_ = Movie(fromRepresentation: movieRep, onContext: backgroundContext)
						}
					}
				}
				try CoreDataStack.shared.save(context: backgroundContext)
				completion(.success(movieArray))
			} catch {
				completion(.failure(error as? NetworkError ?? NetworkError.otherError(error: error)))
			}
		}
	}


	// MARK: - local persistence

	@discardableResult func create(movieFromRepresentation representation: MovieRepresentation, onContext context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> Movie {
		let movie = Movie(fromRepresentation: representation, onContext: context)
		try? CoreDataStack.shared.save(context: context)
		remotePut(movie: movie) { (result: Result<MovieRepresentation, NetworkError>) in
			do {
				_ = try result.get()
			} catch {
				NSLog("error putting movie \(movie.title ?? ""): \(error)")
			}
		}
		return movie
	}

	func delete(movie: Movie) {
		remoteDelete(movie: movie) { (result: Result<Data?, NetworkError>) in
			do {
				_ = try result.get()
			} catch {
				NSLog("error deleting \(movie.title ?? "") from firebase: \(error)")
			}
		}

		guard let context = movie.managedObjectContext else { return }
		context.performAndWait {
			context.delete(movie)
		}
		try? CoreDataStack.shared.save(context: context)
	}

	func update(watched: Bool, onMovie movie: Movie, onContext context: NSManagedObjectContext) {
		context.performAndWait {
			movie.hasWatched = watched
		}
		do {
			try CoreDataStack.shared.save(context: context)
			NSLog("success saving update for movie: \(movie)")
		} catch {
			NSLog("failure saving update for movie \(movie): \(error)")
		}
		remotePut(movie: movie) { (result: Result<MovieRepresentation, NetworkError>) in
			do {
				_ = try result.get()
			} catch {
				NSLog("error updating movie \(movie.title ?? ""): \(error)")
			}
		}
	}

	func isMovieSaved(withTitle title: String) -> Bool {
		return get(movieWithTitle: title, fromContext: CoreDataStack.shared.mainContext) != nil
	}

	func get(movieWithTitle title: String, fromContext context: NSManagedObjectContext) -> Movie? {
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "title == %@", title)
		var movie: Movie?
		context.performAndWait {
			do {
				movie = try context.fetch(fetchRequest).first
			} catch {
				NSLog("error getting movie from coredata: \(error)")
			}
		}
		return movie

	}

	func get(movieWithUUID uuid: UUID, fromContext context: NSManagedObjectContext) -> Movie? {
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid as NSUUID)
		var movie: Movie?
		context.performAndWait {
			do {
				movie = try context.fetch(fetchRequest).first
			} catch {
				NSLog("error getting movie from coredata: \(error)")
			}
		}
		return movie
	}

	func get(movie: Movie?, fromContext context: NSManagedObjectContext) -> Movie? {
		var identifier: UUID?
		movie?.managedObjectContext?.performAndWait {
			identifier = movie?.identifier
		}
		guard let unwrappedID = identifier else { return nil }
		return get(movieWithUUID: unwrappedID, fromContext: context)
	}
}
