//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Moin Uddin on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var movie: Movie?
    
    @IBAction func addMovie(_ sender: Any) {
    }
    
    @IBOutlet weak var movieTitle: UILabel!
    
    
    

}
