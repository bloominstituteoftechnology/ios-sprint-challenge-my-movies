//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Mark Poggi on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

      
    @IBOutlet weak var watchedMovieButton: UIButton!
    
    var movie: Movie? {
           didSet {
               updateViews()
           }
       }
    

    @IBAction func addMovie(_ sender: UIButton) {
        sender.setTitle("Testing", for: .normal)
        guard let movie = movie else { return }
        
        
      
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    private func updateViews() {
        guard let movie = movie else { return }
 
    }
    

}
