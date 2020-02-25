//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Gerardo Hernandez on 2/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    
    // MARK: - Properties
    
    var title: String? {
        didSet{
            movieTitleLable.text = title
        }
    }
    // MARK: - IBOutlets
    @IBOutlet weak var movieTitleLable: UILabel!
    
    //MARK: - IBActions
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
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
