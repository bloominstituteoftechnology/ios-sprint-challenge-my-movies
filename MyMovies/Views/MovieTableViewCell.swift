//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Cameron Collins on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var movieNameLabel: UILabel!
    
    //MARK: - Actions
    @IBAction func movieAddButtonPressed(_ sender: UIButton) {
        
        //Unwrapping text
        guard let text = movieNameLabel.text else {
            return
        }
        
        //Add Movie to the CoreDataStack and save it
        Movie(title: text, hasWatched: false)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("Error saving Movie to CoreData in MovieTableViewCell: \(error)")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
