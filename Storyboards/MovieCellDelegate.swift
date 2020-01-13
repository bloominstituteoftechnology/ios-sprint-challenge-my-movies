//
//  MovieCellDelegate.swift
//  MyMovies
//
//  Created by Angelique Abacajan on 1/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieCellDelegate {
    func buttonTapped(for movie: Movie)
}
