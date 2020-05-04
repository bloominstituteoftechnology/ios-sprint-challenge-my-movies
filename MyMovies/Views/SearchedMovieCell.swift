//
//  SearchedMovieCell.swift
//  MyMovies
//
//  Created by Waseem Idelbi on 5/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchedMovieCell: UITableViewCell {
    
    //MARK: - Properties and IBOutlets -
    
    @IBOutlet var titleLabel: UILabel!
    
    //MARK: - Methods and IBActions -
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let context = CoreDataStack.shared.mainContext
        let movie = Movie(title: titleLabel.text!, hasWatched: false, identifier: UUID(), context: context)
        let movieController = MovieController()
        movieController.sendMovieToServer(movie)
        movieController.save(context: CoreDataStack.shared.mainContext)
        
    }
    
} //End of class
