//
//  AddedMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Bhawnish Kumar on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
protocol AddedMoviesTableViewCellDelegate {
    func itHasWatched(to movie: Movie)
}
class AddedMoviesTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var movieWatchedButton: UIButton!
    
    var delegate: AddedMoviesTableViewCellDelegate?
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    var movieController: MovieController?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    private func updateViews() {
        CoreDataStack.shared.mainContext.perform {
            guard let movie = self.movie else { return }
            
            self.titleLabel?.text = movie.title
            
            let buttonTitle = movie.hasWatched ? "Watched" : "Unwatched"
            
            self.movieWatchedButton?.setTitle(buttonTitle, for: .normal)
            
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    @IBAction func watchedButtonAction(_ sender: UIButton) {
        guard let movie = movie else { return }
              movie.hasWatched.toggle()
              
              movieWatchedButton.setTitle(movie.hasWatched ? "Watched" : "Unwatched", for: .normal)

              movieController?.sendMovieToServer(movie: movie)
              do {
                  try CoreDataStack.shared.save()
              } catch {
                  NSLog("Error saving: \(error)")
              }
        
    }
    
}

