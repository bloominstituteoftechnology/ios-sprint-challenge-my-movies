//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Daniela Parra on 9/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var movieLabel: UILabel!
    
}
