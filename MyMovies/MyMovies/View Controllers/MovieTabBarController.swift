//
//  MovieTabBarController.swift
//  MyMovies
//
//  Created by Kobe McKee on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

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
