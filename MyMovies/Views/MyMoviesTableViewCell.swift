//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Shawn James on 5/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol WasWatchedButtonWasPressedDelegate {
    func reloadTableView()
}

class MyMoviesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var wasWatchedButton: UIButton!
    
    var movie: Movie?
    var movieController: MovieController?
    var wasWatchedButtonDelegate: WasWatchedButtonWasPressedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        updateViews()
    }
    
    @IBAction func wasWatchedButton(_ sender: Any) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
    
        let updatedMovie = movie
            
        movieController?.sendMovieToServer(movie: updatedMovie)
        movieController?.deleteMovieFromServer(movie: movie)

        
        do {
            try CoreDataManager.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
            return
        }
                
        updateViews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.wasWatchedButtonDelegate?.reloadTableView()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        wasWatchedButton.setTitle(movie.hasWatched == true ? "Watched" : "Not Watched",
                                  for: .normal)
    }
    
}
