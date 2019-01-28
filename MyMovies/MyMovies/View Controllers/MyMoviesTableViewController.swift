//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
//  Helpful Website
//  https://stackoverflow.com/questions/190908/how-can-i-disable-the-uitableview-selection
//  How to turn off selection of rows, which was annoying...
//  https://www.youtube.com/watch?v=Q8k9E1gQ_qg
//  Make sections collapsible. Doesn't work with FetchResultController... sad panda
//  https://stackoverflow.com/questions/25002017/how-to-change-font-of-uibutton-with-swift
//  Learn how to change button font



import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var sectionExpandedInfo : [Bool] = []
    var movieController = MovieController()
    let movieRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieRefreshControl.addTarget(self, action: #selector(beginRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = movieRefreshControl
    }
    
    @IBAction func beginRefresh(_ sender: UIRefreshControl) {
        movieController.fetchMoviesFromServer { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                sender.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        //This makes all the cell non-selectable...
        //tableView.allowsSelection = false
        
    }
    
    // MARK: - Properties
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: false)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc,
                                             sectionNameKeyPath: "hasWatched",
                                             cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        // Added for collapsing function
        sectionExpandedInfo = []
        for _ in frc.sections! {
            sectionExpandedInfo.append(true)
        }
        return frc
    }()
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionExpandedInfo[section] {
            let sectionInfo = self.fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as! MyMoviesTableViewCell
        cell.movie = fetchedResultsController.object(at: indexPath)
        //This would make each cell non-selectable.
        cell.selectionStyle = .none
        return cell
    }
    
     // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let movie = fetchedResultsController.object(at: indexPath)
        movieController.deleteMovie(movie: movie)
    }

    
    // MARK: - NSFetchResultsControllerDelgate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: oldIndexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            // Because the FRC inserts sections, I have to update the sectionExpandedInfo array
            // to include the extra section:
            sectionExpandedInfo.insert(true, at: sectionIndex)
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            // Because the FRC deletes sections, I have to update the sectionExpandedInfo array
            // to remove the extra section:
            sectionExpandedInfo.remove(at: sectionIndex)
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (self.fetchedResultsController.sections!.count > 0) {
            let sectionInfo = self.fetchedResultsController.sections![section]
            let sectionHeaderButton = UIButton(type: .custom)
            sectionHeaderButton.backgroundColor = #colorLiteral(red: 0.702133566, green: 0.1309964703, blue: 0.04411000564, alpha: 1)
            sectionHeaderButton.setTitleColor(.black, for: .normal)
            sectionHeaderButton.titleLabel?.font = UIFont(name: "Copperplate", size: 20.0)!
            sectionHeaderButton.titleLabel?.textAlignment = .right
            
            sectionHeaderButton.tag = section
            if sectionInfo.name == "0" {
                sectionHeaderButton.setTitle("Not Watched", for: .normal)
            } else {
                sectionHeaderButton.setTitle("Watched", for: .normal)
            }
            sectionHeaderButton.addTarget(self, action: #selector(toggleSection), for: .touchUpInside)
            return sectionHeaderButton
        } else {
            return nil
        }
    }
    
    @objc func toggleSection(sender: UIButton) {
        for (index, frcSection) in self.fetchedResultsController.sections!.enumerated() {
            if sender.tag == Int(frcSection.name) {
                sectionExpandedInfo[index] = !sectionExpandedInfo[index]
                self.tableView.reloadSections(NSIndexSet(index: index) as IndexSet, with: .automatic)
            }
        }
    }

//    OLD overrides not needed.
//    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor.black
//        header.textLabel?.frame = header.frame
//        header.textLabel?.textAlignment = .left
//        header.textLabel?.font = UIFont(name: "Copperplate", size: 40)!
//    }
//
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = .black
//        header.textLabel?.backgroundColor = .white
//        header.textLabel?.textAlignment = .left
//        header.textLabel?.font = UIFont(name: "Copperplate", size: 40)!
//    }
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if fetchedResultsController.sections?[section].name == "1" {
//            return "Watched"
//        } else {
//            return "Not Watched"
//        }
//    }
}
