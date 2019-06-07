//
//  MovieTabBarViewController.swift
//  MyMovies
//
//  Created by Hayden Hastings on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTabBarViewController: UITabBarController {
    
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
