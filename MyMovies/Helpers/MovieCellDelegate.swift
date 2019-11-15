//
//  MovieCellDelegateProtocol.swift
//  MyMovies
//
//  Created by morse on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieCellDelegate {
    func buttonTapped(for movie: Movie)
}
