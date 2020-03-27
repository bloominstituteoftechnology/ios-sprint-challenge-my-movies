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

        // Do any additional setup after loading the view.
    }
    


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let movieSearchTVC = segue.destination as? MovieSearchTableViewController {
            movieSearchTVC.movieController = movieController
        } else if let myMoviesTVC = segue.destination as? MyMoviesTableViewController {
            myMoviesTVC.movieController = movieController
        }
    }


}
