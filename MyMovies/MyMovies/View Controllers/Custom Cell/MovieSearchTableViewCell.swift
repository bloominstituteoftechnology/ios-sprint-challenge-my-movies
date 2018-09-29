//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Madison Waters on 9/28/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol MovieSearchTableViewCellDelegate: class {
    func saveMovieToList(cell: MovieSearchTableViewCell)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    @IBOutlet weak var movieSearchLabel: UILabel!
    @IBAction func addMovieButtonTapped(_ sender: Any) {
        
        delegate?.saveMovieToList(cell: self)
        
//        The MovieSearchTableViewController should conform to the protocol,
//        then you implement the function. In the function, add a guard statement
//        that creates a title and set that title to the cell’s movieSearchLabel
//        outlet’s text. Then call the movieController’s create method and pass that title in there.
        
//        guard let title = myMoviesTableViewCell?.myMoviesListLabel.text else { return }
//
//        if let movie = movie {
//
//            movie.title = title
//
//            movieController.put(movie: movie)
//
//            do {
//                let moc = CoreDataStack.shared.mainContext
//                try moc.save()
//
//            } catch {
//                NSLog("Error saving managed object context: \(error)")
//            }
//
//        } else {
//            let _ = Movie(title: title)
//
//            do {
//                let moc = CoreDataStack.shared.mainContext
//                try moc.save()
//
//            } catch {
//                NSLog("Error saving managed object context: \(error)")
//            }
//
//        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateView() {
        if let movieRepresentation = movieRepresentation {
            movieSearchLabel.text = movieRepresentation.title
        }
    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet { updateView() }
    }
    var movieController = MovieController()
    var myMoviesTableViewCell: MyMoviesTableViewCell?
    
}
