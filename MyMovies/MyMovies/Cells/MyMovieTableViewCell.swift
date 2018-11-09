import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    
    // MARK:- View updater method
    private func updateViews() {
        guard let movie = movie else { return }
        
        movieTitleLabel.text = movie.title
        
        let watchedStatusText = movie.hasWatched ? "REMOVE FROM WATCHED" : "ADD TO WATCHED"
        watchedStatusButton.setTitle(watchedStatusText, for: .normal)
    }
    
    
    // MARK:- IBActions
    @IBAction func updateWatchedStatus(_ sender: Any) {
        guard let movieController = movieController,
            let movie = movie else { return }
        
        movieController.update(movie: movie)
        updateViews()
    }
    
    
    // MARK:- Properties & types
    var movieController: MovieController? { didSet { updateViews() }}
    var movie: Movie? { didSet { updateViews() }}
    
    // MARK:- IBOutlets
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var watchedStatusButton: UIButton!
    
}
