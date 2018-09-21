//
//  MovieTabBarController.swift
//  MyMovies
//
//  Created by Dillon McElhinney on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTabBarController: UITabBarController {
    
    let movieController = MovieController()

    override func viewDidLoad() {
        super.viewDidLoad()

        for childVC in childViewControllers {
            if let childVC = childVC as? MovieSearchTableViewController {
                childVC.movieController = movieController
            } else if let childVC = childVC as? MyMoviesTableViewController {
                childVC.movieController = movieController
            }
        }
    }

}
