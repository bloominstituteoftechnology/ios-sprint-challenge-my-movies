//
//  MovieCellDelegate.swift
//  MyMovies
//
//  Created by Keri Levesque on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation


protocol MovieCellDelegate {
    func buttonTapped(for movie: Movie)
}
