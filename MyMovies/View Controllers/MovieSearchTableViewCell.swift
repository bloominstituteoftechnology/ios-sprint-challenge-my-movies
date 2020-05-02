//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Breena Greek on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var movieController: MovieController?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        guard let title = movieLabel.text else { return }
        
        let movie = Movie(title: title, context: CoreDataStack.shared.mainContext)
        movieController?.sendMovieToServer(movie: movie, completion: { _ in })
        do {
            try CoreDataStack.shared.mainContext.save()
                    } catch {
            NSLog("Error saving Movie to persistent store: \(error)")
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
