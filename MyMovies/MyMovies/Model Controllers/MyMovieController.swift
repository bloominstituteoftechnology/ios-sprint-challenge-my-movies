//
//  MyMovieController.swift
//  MyMovies
//
//  Created by Michael Flowers on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MyMovieController {
    static var shared = MyMovieController()
    private let baseURL = URL(string: "https://mymoviesprintchallenge.firebaseio.com/")!
    typealias completionHandler = (Error?) -> Void
    
    //MARK: Core Data CRUD functions
    
    func saveToPersistentStore(){
        
    }
}

