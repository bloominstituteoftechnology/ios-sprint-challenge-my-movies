//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jorge Alvarez on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        print("button tapped")
        guard let movie = movie else {return}
        
        movie.hasWatched.toggle()
        let updatedMovie = movie
        movieController?.sendMovieToServer(movie: updatedMovie)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
        print("watched status is now: \(movie.hasWatched)")
    }
    
    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let movie = movie else {return}
        titleLabel.text = movie.title
        if movie.hasWatched {
            buttonLabel.setTitle("Watched", for: .normal)
        }
        else {
            buttonLabel.setTitle("Not Watched", for: .normal)
        }
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
