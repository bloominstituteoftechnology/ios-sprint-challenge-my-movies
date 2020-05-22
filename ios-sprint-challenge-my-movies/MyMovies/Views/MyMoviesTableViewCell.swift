//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Dahna on 5/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "MyMovieCell"
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    var movieController: MovieController?
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seenButton: UIButton!
    
    // MARK: - Actions
    @IBAction func seenButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        sender.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
//            CoreDataStack.shared.mainContext.reset()
            NSLog("Error saving context (changing movie hasWatched boolean): \(error)")
        }
    }
    
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        seenButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
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
