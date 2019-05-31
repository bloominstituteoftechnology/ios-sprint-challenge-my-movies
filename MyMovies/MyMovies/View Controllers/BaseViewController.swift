//
//  BaseViewController.swift
//  MyMovies
//
//  Created by Michael Redig on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class BaseViewController: UITabBarController {
	let movieController = MovieController()

	override func viewDidLoad() {
		super.viewDidLoad()

		guard let viewControllers = viewControllers else { return }
		for viewController in viewControllers {
			if let movieControllerProt = viewController as? MovieControllerProtocol {
				movieControllerProt.movieController = movieController
			}
		}
	}
}
