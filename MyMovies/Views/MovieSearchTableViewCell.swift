//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Isaac Lyons on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var movieRepresentation: MovieRepresentation!
    var movieController: MovieController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        titleLabel.text = movieRepresentation.title
    }

    @IBAction func addMovieTapped(_ sender: UIButton) {
        //print(movieRepresentation.title)
        movieController.addMovie(movieRepresentation, context: CoreDataStack.shared.mainContext)
    }
}
