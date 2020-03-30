//
//  MainTabBarController.swift
//  MyMovies
//
//  Created by Shawn Gee on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    private let movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let movieSearchTVC = children[0] as? MovieSearchTableViewController else { return }
        guard let myMoviesTVC = children[1] as? MyMoviesTableViewController else { return }
        
        movieSearchTVC.movieController = movieController
        myMoviesTVC.movieController = movieController
    }
}
