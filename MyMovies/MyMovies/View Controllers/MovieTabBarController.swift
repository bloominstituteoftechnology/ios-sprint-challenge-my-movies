//
//  MovieTabBarController.swift
//  MyMovies
//
//  Created by Jerrick Warren on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTabBarController: UITabBarController {
    
    let movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for childVC in children {
            if let childVC = childVC as? MovieProtocol {
                childVC.movieController = movieController
            }
        }
    }
        
    
}
