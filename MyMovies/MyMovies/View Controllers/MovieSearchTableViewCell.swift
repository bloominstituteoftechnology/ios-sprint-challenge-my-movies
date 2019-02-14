
import UIKit

extension NSNotification.Name {
    static let shouldShowMovieAdded = NSNotification.Name("ShouldShowMovieAdded")
}

protocol MovieSearchTableViewCellDelegate: class {
    func addMovie(cell: MovieSearchTableViewCell, movie: MovieRepresentation)
}

class MovieSearchTableViewCell: UITableViewCell {
    
    // Holds the reference to our delegate
    weak var delegate: MovieSearchTableViewCellDelegate?
    
    static let reuseIdentifier = "MovieCell"
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var movieButtonOutlet: UIButton!
    
    @IBAction func addMovieButton(_ sender: Any) {
        
        // Make sure we have a movie
        guard let movieRepresentation = movieRepresentation else { return }
        
        // When tapped, call the delegate's function with the cell that was tapped (self), and the movie
        delegate?.addMovie(cell: self, movie: movieRepresentation)
        
        // Change the title of the button to "Saved"
        movieButtonOutlet.setTitle("Saved", for: .normal)
        
        // Deactivate the button
        movieButtonOutlet.isEnabled = false
        
        // Post a notification when button is tapped indicating a movie has been saved
        NotificationCenter.default.post(name: .shouldShowMovieAdded, object: self)

    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        
        // Set the cell's text to the passed movie title
        movieTitleLabel.text = movieRepresentation?.title
        
        movieButtonOutlet.isEnabled = true
        movieButtonOutlet.setTitle("Add Movie", for: .normal)
        
    }
    
    
}
