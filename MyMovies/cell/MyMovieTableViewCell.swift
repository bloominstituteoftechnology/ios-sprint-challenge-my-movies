//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Lydia Zhang on 3/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit


class MyMovieTableViewCell: UITableViewCell {
    
    var movieController: MovieController?
    @IBOutlet weak var myMovieTitle: UILabel!
    @IBOutlet weak var hasWatched: UIButton!

    var movie: Movie? {
        didSet{
            updateView()
        }
    }
    
    func updateView() {
        guard let movie = movie else {return}
        myMovieTitle.text = movie.title
        if movie.hasWatched == false {
            hasWatched.setTitle("Not Watched", for: .normal)
        } else {
            hasWatched.setTitle("Watched", for: .normal)
        }
    }
    @IBAction func hasWatchToggle(_ sender: Any) {
        guard let movie = movie else {return}
        movie.hasWatched.toggle()
        movieController?.put(movie: movie)
        try! CoreDataStack.shared.save()
        if movie.hasWatched == false {
            hasWatched.setTitle("Not Watched", for: .normal)
        } else {
            hasWatched.setTitle("Watched", for: .normal)
        }
        
    }
    

}
