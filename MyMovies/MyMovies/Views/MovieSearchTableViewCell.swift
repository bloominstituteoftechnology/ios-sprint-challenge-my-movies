//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Seschwan on 7/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieLbl: UILabel!
    @IBOutlet weak var addMovieBtn: UIButton!
    
    weak var movieSearchDelegate: MovieSearchTVCDelegate?

    override func awakeFromNib() {
        addMovieBtn.layer.cornerRadius = 5
    }
    
    @IBAction func addMovieBtnPressed(_ sender: UIButton) {
        movieSearchDelegate?.saveMoviesToList(cell: self)
        //disableButton()
    }
    
    func disableButton() {
        addMovieBtn.setTitle("Added", for: .normal)
        addMovieBtn.isSelected = true
        addMovieBtn.isEnabled = false
        addMovieBtn.layer.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
