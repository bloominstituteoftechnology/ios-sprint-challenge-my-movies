//
//  MovieSearchCell.swift
//  MyMovies
//
//  Created by Chad Parker on 5/1/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchCell: UITableViewCell {
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func updateViews() {
        movieTitleLabel.text = movieRepresentation?.title
    }

    @IBAction func save(_ sender: Any) {
        guard let movieRep = movieRepresentation,
            let movie = Movie(movieRepresentation: movieRep) else { fatalError() }
        
        let movieController = MovieController()
        movieController.put(movie: movie, completion: { _ in })
        
        do {
            try CoreDataStack.shared.mainContext.save()
            saveButton.setTitle("SAVED", for: .normal)
            saveButton.setTitleColor(.black, for: .normal)
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
