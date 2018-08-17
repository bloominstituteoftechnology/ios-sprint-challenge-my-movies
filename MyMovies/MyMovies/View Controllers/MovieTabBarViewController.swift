//
//  MovieTabBarViewController.swift
//  MyMovies
//
//  Created by Linh Bouniol on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTabBarViewController: UITabBarController {

    let movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passMovieControllerToChildViewControllers()
    }
    
    func passMovieControllerToChildViewControllers() {
        for child in childViewControllers {
            guard let vc = child as? MovieControllerProtocol else { return }
            vc.movieController = movieController
        }
    }

}
