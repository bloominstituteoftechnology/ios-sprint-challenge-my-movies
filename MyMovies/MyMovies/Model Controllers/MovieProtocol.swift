//
//  MovieProtocol.swift
//  MyMovies
//
//  Created by Victor  on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieProtocol: class {
    var movieController: MovieController? {get set}
}
