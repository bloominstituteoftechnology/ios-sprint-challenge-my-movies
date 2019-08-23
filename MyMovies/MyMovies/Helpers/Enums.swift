//
//  Enums.swift
//  MyMovies
//
//  Created by Jeffrey Santana on 8/23/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

enum NetworkError: Error {
	case badURL
	case noToken
	case noData
	case notDecoding
	case notEncoding
	case other(Error)
}

enum HTTPMethod: String {
	case get = "GET"
	case put = "PUT"
	case post = "POST"
	case delete = "DELETE"
}
