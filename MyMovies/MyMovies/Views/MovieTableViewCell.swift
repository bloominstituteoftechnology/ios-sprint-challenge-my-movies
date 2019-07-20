//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Seschwan on 7/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieLbl: UILabel!
    @IBOutlet weak var addMovieBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        addMovieBtn.layer.cornerRadius = 5
        //addMovieBtn.layer.backgroundColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
