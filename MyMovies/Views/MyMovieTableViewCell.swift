//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Cameron Collins on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MyMovieTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //MARK: - Variables
    var movie: Movie? {
        didSet {
            titleLabel.text = movie?.title
            switch movie?.hasWatched {
            case true:
                seenMovieButton.setTitle("HasSeen", for: .normal)
            case false:
                seenMovieButton.setTitle("NotSeen", for: .normal)
            default:
                seenMovieButton.setTitle("NotSeen", for: .normal)
            }
            
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seenMovieButton: UIButton!
    
    //MARK: - Actions
    @IBAction func seenMoviePressed(_ sender: UIButton) {
        
        guard let movie = movie else {
            return
        }
        
        movie.hasWatched = !movie.hasWatched
        
        switch movie.hasWatched {
        case true:
            sender.setTitle("HasSeen", for: .normal)
        case false:
            sender.setTitle("NotSeen", for: .normal)
        }
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("Error saving to context: \(error)")
        }
    }
}
