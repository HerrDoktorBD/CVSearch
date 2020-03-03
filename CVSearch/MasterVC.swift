/**
 * Copyright (c) 2017 Razeware LLC
 */

import UIKit

class MasterVC: UIViewController,
                UITableViewDataSource,
                UITableViewDelegate {

    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!

    var detailViewController: DetailVC? = nil
    var candies = [Candy]()
    var filteredCandies = [Candy]()

    lazy var searchController: UISearchController = {

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        let sb = searchController.searchBar
        sb.delegate = self
        sb.placeholder = "Search Candy"

        // scope bar
        sb.scopeButtonTitles = [
            "All",
            "Chocolate",
            "Hard",
            "Other"
        ]

        return searchController
    }()

    lazy var searchBtnItem: UIBarButtonItem = {

        return UIBarButtonItem(barButtonSystemItem: .search,
                               target: self,
                               action: #selector(searchTapped(_:)))
    }()

    // MARK: - View Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(#function)

        // setup the search footer
        tableView.tableFooterView = searchFooter

        candies = [
            Candy(category: "Chocolate", name: "Chocolate Bar"),
            Candy(category: "Chocolate", name: "Chocolate Chip"),
            Candy(category: "Chocolate", name: "Dark Chocolate"),
            Candy(category: "Hard", name: "Lollipop"),
            Candy(category: "Hard", name: "Candy Cane"),
            Candy(category: "Hard", name: "Jaw Breaker"),
            Candy(category: "Other", name: "Caramel"),
            Candy(category: "Other", name: "Sour Chew"),
            Candy(category: "Other", name: "Gummi Bear"),
            Candy(category: "Other", name: "Candy Floss"),
            Candy(category: "Chocolate", name: "Chocolate Coin"),
            Candy(category: "Chocolate", name: "Chocolate Egg"),
            Candy(category: "Other", name: "Jelly Beans"),
            Candy(category: "Other", name: "Liquorice"),
            Candy(category: "Hard", name: "Toffee Apple")
        ]

        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailVC
        }

        navigationItem.rightBarButtonItem = searchBtnItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print(#function)

        if splitViewController!.isCollapsed {
            if let selectionIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectionIndexPath, animated: animated)
                //print("tableView.deselectRow")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print(#function)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
            return filteredCandies.count
        }

        searchFooter.setNotFiltering()
        return candies.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        let candy: Candy
        if isFiltering() {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        cell.textLabel!.text = candy.name
        cell.detailTextLabel!.text = candy.category

        return cell
    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {

        if segue.identifier == "showDetail" {

            if let indexPath = tableView.indexPathForSelectedRow {

                let candy: Candy
                if isFiltering() {
                    candy = filteredCandies[indexPath.row]
                } else {
                    candy = candies[indexPath.row]
                }
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailVC
                vc.detailCandy = candy
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Private instance methods
    func filterContentForSearchText(_ searchText: String,
                                    scope: String = "All") {

        filteredCandies = candies.filter({( candy: Candy) -> Bool in

            let doesCategoryMatch = (scope == "All") || (candy.category == scope)

            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
            }
        })

        refresh()
    }

    func searchBarIsEmpty() -> Bool {

        let sb = searchController.searchBar
        return sb.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {

        let sb = searchController.searchBar
        let searchBarScopeIsFiltering = sb.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    func refresh() {

        tableView.reloadData()
    }

    // MARK: - action methods

    @objc func forceNavHeightReset() {

        /*
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {

            let vc = UIViewController()

            self.navigationController?.pushViewController(vc, animated: false)
            self.navigationController?.popViewController(animated: false)

        }, completion: nil)
 */
        self.navigationController?.view.setNeedsLayout()
        self.navigationController?.view.layoutIfNeeded()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        showSearchBar(show: false)
    }

    @objc func searchTapped(_ sender: Any) {

        showSearchBar(show: self.navigationItem.searchController == nil)
    }

    func showSearchBar(show: Bool) {

        let sb = searchController.searchBar

        if show {
            //print("show searchbar")

            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: {

                if #available(iOS 13, *) {
                    self.navigationItem.searchController = self.searchController
                }

            }, completion: { (status) in

                sb.becomeFirstResponder()
            })
        }
        else {
            //print("hide searchbar")

            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: {

                sb.resignFirstResponder()

            }, completion: { (status) in

                if #available(iOS 13, *) {
                    self.navigationItem.searchController = nil
                }

                // this will force a reset of the navigationItem height
                self.perform(#selector(self.forceNavHeightReset),
                             with: nil,
                             afterDelay: 0.1)
            })
        }
    }
}

// MARK: - UISearchBar Delegate

extension MasterVC: UISearchBarDelegate {

    func searchBar(_ sb: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int) {

        if let sbt = sb.scopeButtonTitles {
            let scope = sbt[selectedScope]
            filterContentForSearchText(sb.text!,
                                       scope: scope)
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension MasterVC: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        let sb = searchController.searchBar

        if let sbt = sb.scopeButtonTitles {
            let scope = sbt[sb.selectedScopeButtonIndex]
            filterContentForSearchText(sb.text!,
                                       scope: scope)
        }
    }
}
