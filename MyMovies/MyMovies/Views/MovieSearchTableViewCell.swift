//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Alex on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var addMovieBtn: UIButton!
    
    // MARK: - Actions
    
    @IBAction func addMovieBtnPressed(_ sender: UIButton) {
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
