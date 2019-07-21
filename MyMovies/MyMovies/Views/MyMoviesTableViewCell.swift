//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Seschwan on 7/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myMoviesLbl: UILabel!
    @IBOutlet weak var hasWatchedBtn: UIButton!
    
    weak var movieListDelegate: MovieListTVCDelegate?
    
    var movie: Movie? {
        didSet {
            self.updateViews()
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        hasWatchedBtn.layer.cornerRadius = 5
        
    }

    @IBAction func hasWatchedBtnPressed(_ sender: UIButton) {
        movieListDelegate?.hasWatchedToggle(cell: self)
    }
    
    func updateViews() {
        guard let movie = self.movie else { return }
        
        self.myMoviesLbl.text = movie.title
        
        if movie.hasWatched {
            hasWatchedBtn.setTitle("Watched", for: .normal)
            hasWatchedBtn.layer.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else {
            hasWatchedBtn.setTitle("Not Seen", for: .normal)
            hasWatchedBtn.layer.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
