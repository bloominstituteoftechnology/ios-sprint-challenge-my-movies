//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Jonathan Ferrer on 6/7/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // where we'll call save to coredata and put
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        guard let title = titleLabel.text else { return }

        _ = Movie(title: title, hasWatched: false)

        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
            print("Saved item")
        } catch {
            NSLog("Error saving managed object context: \(error)")
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

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var addButton: UIButton!

    


}
