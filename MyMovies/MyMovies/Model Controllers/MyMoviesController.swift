//
//  MyMoviesController.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class MyMoviesController {
	
	
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
				print(movieReps)
				completion(nil)
			} catch {
				print("Error decoding movies from firebase: \(error)")
			}
			
		}.resume()
	}
	
	
	let baseUrl = URL(string: "https://movies-c2ab5.firebaseio.com/")!
}
