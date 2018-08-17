//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Andrew Dhan on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

private let moc = CoreDataStack.shared.mainContext

class MyMovieTableViewCell: UITableViewCell {
    
    @IBAction func toggleHasWatched(_ sender: Any) {
        guard let movie = movie else {return}
 
        movie.hasWatched = !movie.hasWatched
        do{
            try moc.save()
        } catch {
            NSLog("Error saving changes: \(error)")
            moc.reset()
            return
        }
        updateCell()
        
    }
    
    func updateCell(){
        guard let movie = movie,
            let title = movie.title else {return}
        let hasWatched = movie.hasWatched ? "Watched" : "Unwatched"
        
        titleLabel.text = title
        hasWatchedOutlet.setTitle(hasWatched, for: .normal)
    }
    
    
    //MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedOutlet: UIButton!
    
    var movie: Movie? {
        didSet{
            updateCell()
        }
    }
    
}
