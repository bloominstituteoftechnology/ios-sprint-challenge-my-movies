
import UIKit

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

    }
    
    var movieRepresentation: MovieRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        
        // Set the cell's text to the passed movie title
        movieTitleLabel.text = movieRepresentation?.title
        
    }
    
    
}
