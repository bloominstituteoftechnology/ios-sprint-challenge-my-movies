//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Taylor Lyles on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class SearchTableViewCell: UITableViewCell {
	
    var hasBeenAdded: Bool = false
    
    var movieController: MovieController?
    
    var movie: MovieRepresentation? {
        didSet {
            setViews()
        }
    }
	
    override func awakeFromNib() {
        setViews()
    }
    
	 func setViews() {
		   
		   titleLabel.text = movie?.title
		   
		   if hasBeenAdded == false {
				addMovie.setTitle("Add Movie", for: .normal)
		   } else if hasBeenAdded == true {
			   addMovie.setTitle("Movie Added", for: .normal)
		   }
	   }
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var addMovie: UIButton!
	
	@IBAction func addButton(_ sender: Any) {
		hasBeenAdded = !hasBeenAdded
			   guard let title = titleLabel.text else {return}
			   movieController?.addMovie(with: title)
			   CoreDataStack.shared.save()
	}
}
