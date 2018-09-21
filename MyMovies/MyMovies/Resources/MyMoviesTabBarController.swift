//
//  MyMoviesTabBarController.swift
//  MyMovies
//
//  Created by Farhan on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTabBarController: UITabBarController {

    var movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
            for childVC in childViewControllers {
                if let childVC = childVC as? MovieSearchTableViewController {
                    childVC.movieController = movieController
                }
                else if let childVC = childVC as? MyMoviesTableViewController {
                    childVC.movieController = movieController
                }
            }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
