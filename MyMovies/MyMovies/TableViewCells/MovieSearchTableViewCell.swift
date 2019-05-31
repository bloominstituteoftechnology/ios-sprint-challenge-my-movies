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
		
//		let movie =
		
		// put method should send MovieRep to firebase
//		myMovieController?.put(movie: <#T##Movie#>, completion: <#T##(Error?) -> ()#>)
		
		// save to store
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
	
	func put(entry: Movie, completion: @escaping (Error?) -> ()) {
		
	}
	
	private func setupViews() {
		titleLable?.text = movieRep?.title
	}
	
	@IBOutlet var titleLable: UILabel!
	var movieRep: MovieRepresentation? { didSet { setupViews() } }
	var myMovieController: MyMoviesController?
}
