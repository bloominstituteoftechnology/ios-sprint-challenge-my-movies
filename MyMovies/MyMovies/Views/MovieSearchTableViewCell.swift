//
//  MovieSearchTableViewCell.swift
//  MyMovies
//
//  Created by Alex on 5/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewCell: UITableViewCell {

    // MARK: - Constants
    
    var movie: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var addMovieBtn: UIButton!
    
    // MARK: - Actions
    
    @IBAction func addMovieBtnPressed(_ sender: UIButton) {
        let moc = CoreDataStack.shared.mainContext
        
        guard let movie = movie else {return} // problem here
        print(movie)
        titleLbl.text = movie.title
        
        do {
            print("Saving movie... addMovieBtnPressed")
            try moc.save()
            sender.setTitle("Added", for: .normal)
        } catch {
            NSLog("Error saving movie: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Functions
    
    func updateViews(){
        print("running update views")
        guard let movie = movie else {return}
        print("received movie: ", movie)
        titleLbl.text = movie.title
    }
    
    // MARK: - VC Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
