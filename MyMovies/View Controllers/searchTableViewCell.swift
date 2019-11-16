//
//  searchTableViewCell.swift
//  MyMovies
//
//  Created by Thomas Sabino-Benowitz on 11/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class searchTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    
    @IBOutlet weak var saveButton: UIButton!
    
    var movieRepresentation: MovieRepresentation?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func saveTapped(_ sender: Any) {
        if let movieRepresentation = movieRepresentation {
            let movie = Movie(title: movieRepresentation.title, identifier: nil, hasWatched: nil, context: CoreDataStack.shared.mainContext)
            
            movieController?.sendTaskToServer(movie: movie)
            
            
            
            
        }
    }
}


