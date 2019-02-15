//
//  SearchMovieTableViewCell.swift
//  MyMovies
//
//  Created by Jocelyn Stuart on 2/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBAction func addMovieTapped(_ sender: Any) {
    
    }
    

}
