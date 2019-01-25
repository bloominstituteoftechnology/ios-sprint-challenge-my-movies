//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Sergey Osipyan on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var searchMovieTitleLabel: UILabel!
    @IBOutlet weak var movieSearchAddButton: UIButton!
    @IBAction func movieSearchAddButtonAction(_ sender: Any) {
        
    }
    
}
