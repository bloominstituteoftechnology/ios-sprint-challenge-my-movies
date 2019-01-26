

import UIKit

class MyMoviesTableViewCell: UITableViewCell {
    
    var movieDataController: MovieDataController?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var hasWatchedOutlet: UIButton!
    
    @IBAction func hasWatchedAction(_ sender: Any) {
        
        guard let movie = movie else { return }
        
        //movie?.hasWatched == true
        
        movieDataController?.updateMovie(movie: movie, hasWatched: true)
        
    }
    
    static let reuseIdentifier = "MyMovieCell"
    
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        movieTitleLabel.text = movie?.title
    }
    
    
}
