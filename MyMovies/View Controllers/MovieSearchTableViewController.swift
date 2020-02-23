//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
   var movieController = MovieController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        MovieController.sharedInstance.searchForMovie(with: searchTerm) { (error) in
//            movieController.searchForMovie(with: searchTerm)
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
     
    // Add Movie Button ( DidSelect with label but selection of row)
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           MovieController.sharedInstance.createSavedMovie(title: MovieController.sharedInstance.searchedMovies[indexPath.row].title)
           
           let title = MovieController.sharedInstance.searchedMovies[indexPath.row].title
        
        
           // ADD an Alert to let user know?
           let alert = UIAlertController(title: "\(title)", message: "Added to Movie list", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Return", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
       }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return movieController.searchedMovies.count
        return MovieController.sharedInstance.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
//        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        cell.textLabel?.text = MovieController.sharedInstance.searchedMovies[indexPath.row].title
        
        return cell
    }
    
   
  
     @IBAction func watchedTapped(_ sender: UIButton) {
        
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
}
