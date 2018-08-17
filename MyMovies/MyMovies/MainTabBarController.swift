//
//  MainTabBarController.swift
//  Poll
//
//  Created by Simon Elhoej Steinmejer on 26/07/18.
//  Copyright © 2018 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    let movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for childViewController in childViewControllers
        {
            if let vc = childViewController as? MoviePresenter
            {
                vc.movieController = movieController
            }
        }
    }


}
