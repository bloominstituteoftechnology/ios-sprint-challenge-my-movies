//
//  MovieProtocol.swift
//  MyMovies
//
//  Created by Jerrick Warren on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieProtocol: class {
    var movieController: MovieController? {get set}
}
