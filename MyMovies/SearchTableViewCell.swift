//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by admin on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    var movie: Movie?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMovieButton(_ sender: Any) {
        
    }
    

}
