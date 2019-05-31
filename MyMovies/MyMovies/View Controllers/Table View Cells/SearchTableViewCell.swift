//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Michael Flowers on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class SearchTableViewCell: UITableViewCell {
    
    //MARK: Properties
    var movie: Movie? {
        didSet {
            print("movie passed")
            updateViews()
        }
    }
    var mc: MovieController?
    
    
    //MARK: IBOutlets
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var addMovieButtonProperties: UIButton!
    
    // MARK: IBActions
    @IBAction func addMovie(_ sender: UIButton) {
        //save this movie in core data
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try CoreDataStack.shared.save(context: backgroundContext)
            } catch {
                print("humpty: \(error.localizedDescription)")
            }
        }
       
    }
    
    private func updateViews(){
        guard let passedInMovie = movie else { return }
        movieNameLabel.text = passedInMovie.title
        backgroundColor = .blue
    }
}
