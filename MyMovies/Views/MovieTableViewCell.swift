//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cameron Collins on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var movieNameLabel: UILabel!
    
    //MARK: - Actions
    @IBAction func movieAddButtonPressed(_ sender: UIButton) {
        
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
