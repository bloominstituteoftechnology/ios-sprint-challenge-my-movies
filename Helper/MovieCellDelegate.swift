//
//  MovieCellDelegate.swift
//  MyMovies
//
//  Created by Angelique Abacajan on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieCellDelegate {
    func buttonTapped(for movie: MovieRepresentation)
}
