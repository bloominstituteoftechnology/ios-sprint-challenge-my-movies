import UIKit

class MyMovieTableViewCell: UITableViewCell {
    
    
    // MARK: - Properties
    
    let movieController = MovieController()
    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var buttonLabel: UIButton!
    
    
    // MARK: - IBActions
    
    @IBAction func watchedButtonTapped(_ sender: Any) {
        guard let movie = movie else {
            print("No movie to save")
            return
        }
        movieController.updateWatched(movie: movie)
    }
    
    
    // MARK: - Functions
    
    func updateViews() {
        guard let movie = movie else { return }
        movieName.text = movie.title
        let buttonLabelString = movie.hasWatched ? "Watched" : "Need to Watch"
        
        buttonLabel.setTitle(buttonLabelString, for: .normal)
    }
}
