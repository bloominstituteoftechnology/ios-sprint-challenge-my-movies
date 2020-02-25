//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Kevin Stewart on 2/21/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            
        }
    }
    
    @IBOutlet weak var addMovieLabel: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
