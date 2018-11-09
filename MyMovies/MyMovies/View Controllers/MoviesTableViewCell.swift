//
//  MoviesTableViewCell.swift
//  MyMovies
//
//  Created by Yvette Zhukovsky on 11/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {
    
    
    var movie: Movie?{
        didSet{
            updateViews()
        }
        
    }
    var movieController: MovieController?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateViews(){
        
        guard let movie = movie else {return}
        title.text = movie.title
        if movie.hasWatched {
            watchedButton.setTitle("Watched", for: .normal)
        } else {
            watchedButton.setTitle("Unwatched", for: .normal)
        }
    }
    
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var watchedButton: UIButton!
    
    
    
    @IBAction func status(_ sender: Any) {
        guard let movie = movie else {return}
        movie.hasWatched.toggle()
        movieController?.Update(movie: movie, hasWatched: movie.hasWatched)
        
    }
    
    
}
