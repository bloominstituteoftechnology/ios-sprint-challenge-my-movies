
import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var movieController = MovieController()
    
    var movieDataController: MovieDataController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieSearchTableViewCell.reuseIdentifier, for: indexPath) as? MovieSearchTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        
        cell.movieTitleLabel.text = movieController.searchedMovies[indexPath.row].title
        //cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        
        return cell
    }
    

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func addMovieButton(_ sender: Any) {
        
        
//        if let movie = movie {
//            movieDataController?.updateMovie(movie: movieController.searchedMovies[indexPath.row].title, hasWatched: <#T##Bool#>)
//        }

        
    }
    
    var movie: Movie?
    
}
