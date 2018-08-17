//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Jeremy Taylor on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {
    let firebaseController = FirebaseController()

    @IBOutlet weak var titleLabel: UILabel!
    //FIXME: I don't like doing this here. I would've rather used delegation but I wasn't sure how to get the index of a table view cell from the fetchedResultsController
    @IBAction func addMovie(_ sender: Any) {
        guard let title = titleLabel.text else { return }
        
        let movie = Movie(title: title)
        do {
            firebaseController.put(movie: movie)
            try CoreDataStack.shared.save()
            
        } catch {
            NSLog("Error Saving to Core Data: \(error)")
        }
        
    }
}
