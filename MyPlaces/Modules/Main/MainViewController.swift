//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 26.01.2023.
//

import UIKit
import RealmSwift
 
// MARK: - MainViewController
class MainViewController: UIViewController {
        
// MARK: - UI
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var reversedSortingButton: UIBarButtonItem!
    
// MARK: - Actions
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        isSortingAscending.toggle()
        
        if isSortingAscending == true {
            reversedSortingButton.image = UIImage(named: "AZ")
        } else {
            reversedSortingButton.image = UIImage(named: "ZA")
        }
        
        sorting()
    }
    
// MARK: - Params
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var isSortingAscending =  true
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        self.tableView.contentInset.top = 30
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
// MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String.segueIdentifierShowDetail {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let place: Place
            
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
            let newPlaceViewController = segue.destination as! NewPlaceViewController
            
            newPlaceViewController.currentPlace = place
        }
    }
    
// MARK: - Private methods
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == .zero {
            places = places.sorted(byKeyPath: "date", ascending: isSortingAscending)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: isSortingAscending)
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering { return filteredPlaces.count }
        
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
                        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = Double(place.ratingOfPlace)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeAction
    }
}

// MARK: - UISearchResultsUpdating
extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}

// MARK: - String
private extension String {
    
    static let segueIdentifierShowDetail = "showDetail"
}
