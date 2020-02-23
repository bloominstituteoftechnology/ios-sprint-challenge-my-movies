//
//  MovieCellDelegate.swift
//  MyMovies
//
//  Created by Sal Amer on 2/23/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieCellDelegate {
    func buttonPressed(for movie: Movie)
    }
