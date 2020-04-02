//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by admin on 10/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var added: Bool = false
    
    var movieController: MovieController?
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
      
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
    }

    private func updateViews() {
        
        titleLabel.text = movie?.title
        
        if added == false {
            addedButton.setTitle("Add Movie", for: .normal)
        } else if added == true {
            addedButton.setTitle("Added", for: .normal)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addMovieButton(_ sender: UIButton) {
        
        added = !added
        
        guard let movie = movie else { return }
        
        movieController?.createMovie(with: movie.title, hasWatched: movie.hasWatched, context: CoreDataStack.shared.mainContext)
        
//        movieController?.createMovie(with: title, identifier: identifier, hasWatched: false, context: CoreDataStack.shared.mainContext)
        
    }

}

