//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Chris Gonzales on 2/28/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {

    var movie: Movie?{
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet var watchedButton: UIButton!
    
    @IBAction func watchedToggled(_ sender: UIButton){
        guard let movie = movie else { return }
        do{
            movie.hasWatched.toggle()
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset()
            return
        }
        updateViews()
    }
    
    private func updateViews(){
        guard let movie = movie else { return }
        movieLabel.text = movie.title
        if movie.hasWatched {
            watchedButton.titleLabel?.text = "Watched"
        } else {
            watchedButton.titleLabel?.text = "Unwatched"
        }
    }

}
