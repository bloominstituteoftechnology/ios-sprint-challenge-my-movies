//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by BrysonSaclausa on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
     // MARK: - IBOutlets
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    static let reuseIdentifier = "MyMovieCell"
       
       var movieController: MovieController?
       
       var movie: Movie? {
           didSet {
               updateViews()
           }
       }
    
    private func updateViews() {
            guard let movie = movie else { return }
            
            movieTitleLabel.text = movie.title
            
            updateWatchButton(button: movie.hasWatched)
            
    //        watchedButton.setImage((movie.hasWatched) ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
            

            
        }
    
    
     // MARK: - Actions
    
    
    @IBAction func watchButtonPressed(_ sender: Any) {
        if let movie = movie {
            movieController?.toggleHasWatched(movie)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    private func updateWatchButton(button: Bool) {
           if button {
               watchedButton.setImage(UIImage(systemName: "film.fill"), for: .normal)
           } else {
               watchedButton.setImage(UIImage(systemName: "film"), for: .normal)
           }
       }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
