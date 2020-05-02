//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class MovieController {
    //MARK: - Enums and Type Aliases -
    enum NetworkError: Error {
        case noTitle
        case otherError
        case noData
        case noDecode
        case noEncode
        case noRep
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    
    // MARK: - Properties -
    var searchedMovies: [MovieRepresentation] = []
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    private let firebaseURL = URL(string: "https://mymovies-c63cc.firebaseio.com/")!
    
    
    //MARK: - Actions -
    ///HTTP Actions are listed before local actions
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

    func saveToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
        guard let title = movie.title
            else {
                completion(.failure(.noTitle))
                return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(title).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        do {
            guard let representation = movie.movieRepresentation
                else {
                    completion(.failure(.noRep))
                    return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("error encoding movie representation to server. \(error) \(error.localizedDescription)")
            completion(.failure(.noEncode))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error - something went wrong posting your data to firebase \(error)")
                completion(.failure(.otherError))
                return
            }
            return completion(.success(true))
        }.resume()
    }
    
    
    func saveMovies() {
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save()
        } catch {
           NSLog("error saving managed object context. \(error)")
        }
    }
    
    func updateMovies() {
        
    }
    
    func deleteMovie() {
        
    }
}
