//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Juan M Mariscal on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    
    static let reuseIdentifier = "MovieCell"
    
    // MARK: IBOutlets
    @IBOutlet weak var searchedMovieLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: IBActions
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        guard let title = searchedMovieLabel.text, !title.isEmpty else { return }
        
        let movie = Movie(title: title, hasWatched: false)
        movieController?.sendToFirebase(movie: movie, completion: { _ in })
        do {
            try CoreDataStack.shared.mainContext.save()
            
        } catch {
            NSLog("Error saving movie: \(error)")
        }
    }

}
