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
    }
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
