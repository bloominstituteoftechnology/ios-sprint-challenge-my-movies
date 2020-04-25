//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cody Morley on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: MovieSearchTableViewController?
    var movieRep: MovieRepresentation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func addMovie(_ sender: Any) {
        guard let movieRep = movieRep else { return }
        
        let movie = Movie(movieRepresentation: movieRep)
        delegate?.movieController.saveMovies()
    }
    
    
    
}
