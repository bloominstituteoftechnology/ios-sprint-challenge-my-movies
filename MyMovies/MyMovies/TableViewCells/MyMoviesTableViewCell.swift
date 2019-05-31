//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {


	@IBAction func unwatchedToggleButton(_ sender: Any) {
		print("toggle")
		//change label save to core data and save to firebase
		if let movie = movie {
			movie.hasWatched.toggle()
		}
		// update server with put
		
		do {
			let moc = CoreDataStack.shared.mainContext
			try moc.save()
		} catch {
			NSLog("Error updating movie to moc: \(error)")
		}
		
	}
	
	private func setupViews() {
		guard let movie = movie, let title = movie.title else { return }
		
		titleLabel?.text = title
		let buttonTitle = movie.hasWatched ? "watched" : "unwatched"
		watchedToggleButton.setTitle(buttonTitle, for: .normal)
		
	}
	
	
	@IBOutlet var watchedToggleButton: UIButton!
	@IBOutlet var titleLabel: UILabel!
	var movie: Movie? { didSet {  setupViews() } }
	
	//a controller
}
