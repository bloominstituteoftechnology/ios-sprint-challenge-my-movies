//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Hector Steven on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

	@IBAction func AddMovieButton(_ sender: Any) {
		guard let movieRep = movieRep else { return }
		
		
		print("add \(movieRep.title)movie to firebase")
		
		let movie = Movie(title: movieRep.title)
	
		myMovieController?.put(movie: movie, completion: { error in
			if let error = error {
				print("error putting movie: \(error)")
				return 
			}
		})
		
		do {
			let moc = CoreDataStack.shared.mainContext
			try moc.save()
			print("Saved to store")
		} catch {
			NSLog("Failed to save ->: \(error)")
			//alert
			return
		}
	}

	private func setupViews() {
		titleLable?.text = movieRep?.title
	}
	
	@IBOutlet var titleLable: UILabel!
	var movieRep: MovieRepresentation? { didSet { setupViews() } }
	var myMovieController: MyMoviesController?
}
