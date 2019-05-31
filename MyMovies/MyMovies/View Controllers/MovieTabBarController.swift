//
//  MovieTabBarController.swift
//  MyMovies
//
//  Created by Victor  on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MovieTabBarController: UITabBarController {
    
    let movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for childVC in childViewControllers {
            if let childVC = childVC as? MovieProtocol {
                childVC.movieController = movieController
            }
        }
    }
    
}

