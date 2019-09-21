//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Alex Rhodes on 9/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var hasBeenAdded: Bool = false
    
    var movieController: MovieController?
    
    var movie: MovieRepresentation? {
        didSet {
            setViews()
        }
    }
    
    override func awakeFromNib() {
        
        setViews()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addMovieButton: UIButton!
    
    private func setViews() {
        
        titleLabel.text = movie?.title
        
        if hasBeenAdded == false {
             addMovieButton.setTitle("Add Movie", for: .normal)
        } else if hasBeenAdded == true {
            addMovieButton.setTitle("Movie Added", for: .normal)
        }
       

    }
    
    @IBAction func addMovieButtonTapped(_ sender: UIButton) {
        hasBeenAdded = !hasBeenAdded
        guard let title = titleLabel.text else {return}
        movieController?.createMovie(with: title)
        CoreDataStack.shared.save()
       
    }
}
