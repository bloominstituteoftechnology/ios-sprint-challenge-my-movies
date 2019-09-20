//
//  Constants.swift
//  MyMovies
//
//  Created by Joshua Sharp on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


let coreDataModelName: String = "Movie"
let baseURL = URL(string: "https://mymovie-3cc82.firebaseio.com/")!

enum AppError: Error {
    case objectToRepFailed
}
