//
//  MovieCellDelegateProtocol.swift
//  MyMovies
//
//  Created by Alex Thompson on 12/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

protocol MovieCellDelegate {
    func buttonTapped(for movie: Movie)
}
