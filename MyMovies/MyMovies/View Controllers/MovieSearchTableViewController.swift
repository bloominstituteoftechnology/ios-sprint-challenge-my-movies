//
//  MovieSearchTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self //The controls for the search bar are in this file
    }
    
    //When a search is performed... A.K.A. UISearchBarDelegate instructions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return } //Take the text entered and use it as the search term below.
        
        movieController.searchForMovie(with: searchTerm) { (error) in
            
            guard error == nil else { return } //Stop everything if there's an error
            
            DispatchQueue.main.async { //On a background thread...
                self.tableView.reloadData() //Reload the tableview with the results
            }
        }
    }
    
    
    //Normal TableView Set up
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCellController
        
        //movieController.searchedMovies[indexPath.row].title
        
        return cell
    }
    
    var movieController = MovieController()
    
    @IBOutlet weak var searchBar: UISearchBar!
}
