//
//  SearchTableVC.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class SearchTableVC: UITableViewController, UISearchBarDelegate {
	
	//MARK: - IBOutlets
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	//MARK: - Properties
	
	var movieController = MovieController()
	
	//MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		searchBar.delegate = self
	}
	
	//MARK: - IBActions
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchTerm = searchBar.text else { return }
		
		movieController.searchForMovie(with: searchTerm) { (result) in
			guard try! result.get() else { return }
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	//MARK: - Helpers
	
	
	//MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieController.searchedMovies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        
        cell.textLabel?.text = movieController.searchedMovies[indexPath.row].title
        
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let movie = movieController.searchedMovies[indexPath.row]
		movieController.createMovie(for: movie)
		tabBarController?.selectedIndex = 1
	}
}
