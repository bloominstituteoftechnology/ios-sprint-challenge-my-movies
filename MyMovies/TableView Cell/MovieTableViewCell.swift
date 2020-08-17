//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Norlan Tibanear on 8/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit


protocol MovieTableViewCellDelegate: class {
    func updateMovie(movie: Movie)
}


class MovieTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var watchButton: UIButton!
    
    weak var delegate: MovieTableViewCellDelegate?
    
    static let reuseIdentifier = "MyMovieCell"
    
    var movieController: MovieController?
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        
        watchButton.setImage(movie.hasWatched ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square"), for: .normal)
    }
    
    private func updateWatchButton(button: Bool) {
        if button {
            watchButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            watchButton.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    
    @IBAction func watchBtn(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        movie.hasWatched.toggle()
        
        watchButton.setImage(movie.hasWatched ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square"), for: .normal)
        
        delegate?.updateMovie(movie: movie)
        do {
            try CoreDataStack.shared.mainContext.save()
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

}
