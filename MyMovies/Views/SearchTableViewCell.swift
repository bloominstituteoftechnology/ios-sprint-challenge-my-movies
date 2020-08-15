//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by ronald huston jr on 8/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var beenAdded: Bool = false
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            setViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard let title = titleLabel.text else { return }
        let movie = Movie(title: title, identifier: UUID(), hasWatched: false)!
        movieController?.sendMovieToFirebase(movie: movie)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("error saving managed object context: \(error)")
        }
    }

    private func setViews() {
        //  need to develop ability for user to tap the cell of the movie they want to save
    }
    
    @IBAction func addMovieButton(_ sender: UIButton) {
        guard let title = titleLabel.text else { return }
        
        let movie = Movie(title: title)
        movieController?.sendMovieToFirebase(movie: movie!)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("error saving managed object context: \(error)")
        }
    }
    
}
