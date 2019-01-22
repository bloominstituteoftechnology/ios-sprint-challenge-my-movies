//
//  MovieTBController.swift
//  MyMovies
//
//  Created by Madison Waters on 1/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTBController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        for childVC in childViewControllers {
            guard let movieController = movieController else { return }
            if let childVC = childVC as? MovieSearchTableViewController {
                childVC.movieController = movieController
            } else if let childVC = childVC as? MyMoviesTableViewController {
                childVC.movieController = movieController
            }
        }
    }
    
    let movieController: MovieController? = nil
}
