//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieSearchLabel: UILabel!
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        
        guard let title = myMoviesTableViewCell?.myMoviesListLabel.text else { return }
        
        if let movie = movie {
            
            movie.title = title
            
            movieController.put(movie: movie)

        } else {
            let _ = Movie(title: title)
            
            do {
                let moc = CoreDataStack.shared.mainContext
                try moc.save()
                
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
            
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
    var movie: Movie? {
        didSet{
            
        }
    }
    var movieController = MovieController()
    var myMoviesTableViewCell: MyMoviesTableViewCell?
    
}
