//
//  MovieTVCell.swift
//  MyMovies
//
//  Created by Nikita Thomas on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieTVCell: UITableViewCell {
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var saveButtonLabel: UIButton!
    
    @IBAction func saveButton(_ sender: UIButton) {
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
