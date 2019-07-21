//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Seschwan on 7/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieLbl: UILabel!
    @IBOutlet weak var addMovieBtn: UIButton!
    
    weak var movieSearchDelegate: MovieSearchTVCDelegate?

  
    
    @IBAction func addMovieBtnPressed(_ sender: UIButton) {
        movieSearchDelegate?.saveMoviesToList(cell: self)
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
