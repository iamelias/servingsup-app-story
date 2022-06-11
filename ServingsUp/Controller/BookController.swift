//
//  BookController.swift
//  ServingsUp
//
//  Created by Elias Hall on 1/26/20.
//  Updated 6/9/22
//  Copyright © 2022 Elias Hall. All rights reserved.

import Foundation
import UIKit
import CoreData

class BookController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tapWallView: UIView!
    @IBOutlet weak var noItemsLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var dishListVM: DishListViewModel?
    var dishes: [CoreDish] = []
    var sortT: [CoreSortOption] = [] //holds sort order indicator saved in Core Data
    
    //MARK: VIEW LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegatesDataSources()
        tableViewConfig()
        tapWallConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setToggleActivityIndicator(isOn: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard searchBar.text == "" else {
            tableView.reloadData()
            setToggleActivityIndicator(isOn: false)
            if let dishListVM = dishListVM {
                sortButton.isEnabled = dishListVM.sortIsEnabled
            }
            return
        }
        retrieveCoreDishes()
        dishes = dishes.filter{$0.name != "Untitled"}
        saveContext()
        createDishViewModels()
        tableView.reloadData()
        setToggleActivityIndicator(isOn: false)
        setNoLabelController(isHidden: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tableView.deselectCellRow(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        setToggleActivityIndicator(isOn: false)
    }
    
    func setDelegatesDataSources() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func tapWallConfig() {
        setTapWallController(isHidden: true)
        if let wallColor = UIColor(named: "tap wall color") {
            tapWallView.backgroundColor = wallColor
        } else {
            tapWallView.backgroundColor = .darkGray
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapWallView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func noItemsConfig(itemsPresent: Bool) {
        noItemsLabel.isHidden = itemsPresent
        sortButton.isEnabled = itemsPresent
    }
    
    
    func setToggleActivityIndicator(isOn: Bool) {
        activityIndicator.isHidden = !isOn
        activityIndicator.isHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        // setTapWallController(isHidden: !isOn)
    }
    
    func setTapWallController(isHidden:Bool) {
        tapWallView.layer.opacity = isHidden ? 0.0:0.2
        tapWallView.isHidden = isHidden
    }
    
    func setNoLabelController(isHidden:Bool) {
        guard let dishListVM = dishListVM else {return}
        if (dishListVM.searchState == .searching && dishListVM.searchListIsEmpty) || (dishListVM.searchState == .notSearching && dishListVM.isEmpty) {
            noItemsLabel.isHidden = isHidden
        }
    }
    
    @IBAction func sortButtonDidTouch(_ sender: UIBarButtonItem) {
        createSortActionSheet()
    }
    
    func createDishViewModels() {
        dishListVM = DishListViewModel(dishes: dishes)
        guard let dishListVM = dishListVM else {return}
        
        let array = sortT.compactMap{$0} //removing nils if any
        guard !array.isEmpty else {
            if let context = context {
                let sortOption = CoreSortOption(context:context)
                sortT.append(sortOption)
                dishListVM.setMySort(sort: sortOption)
                dishListVM.sortDishes()
            }
            return
        }
        dishListVM.setMySort(sort: array[array.count-1])
        dishListVM.sortDishes()
    }
    
    func tableViewConfig() {
        tableView.keyboardDismissMode = .onDrag
        noItemsLabel.isHidden = true
    }
    
    func retrieveCoreDishes() { //fetching all dishes by creation date [(earliest)...(Most recent)]
        guard let context = context else {return}
        let fetchRequest: NSFetchRequest<CoreDish> = CoreDish.fetchRequest()
        let sortFetchRequest: NSFetchRequest<CoreSortOption> = CoreSortOption.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true) //last dish is latest dated dish
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dishes = try context.fetch(fetchRequest)
            sortT = try context.fetch(sortFetchRequest)
        }
        catch{
            print("unable to fetch core data")
            return
        }
    }
}
//MARK: TABLE VIEW
extension BookController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dishListVM = dishListVM else {
            return 0
        }
        if dishListVM.dishList.isEmpty && dishListVM.searchState == .notSearching {
            noItemsConfig(itemsPresent: false)
        } else if dishListVM.searchState == .searching && dishListVM.searchListIsEmpty {
            noItemsConfig(itemsPresent: false)
        } else {
            noItemsConfig(itemsPresent: true)
        }
        return dishListVM.numOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! CustomViewCell
        
        //    if let image = dishListVM?.dishAtIndex(at: indexPath.row).image {
        if let image = dishListVM?.dishAtIndex(at: indexPath.row).thumbNailImage {
            cell.cellImage.backgroundColor = .black
            cell.cellImage.image = image
        } else {
            cell.cellImage.backgroundColor = UIColor(named: "cell image background")
            cell.cellImage.image = UIImage(named: "fullCamera2")
            
        }
        cell.cellLabel.text = dishListVM?.dishAtIndex(at: indexPath.row).dishName ?? ""
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let dishListVM = dishListVM else {
            return ""
        }
        return dishListVM.sortOption.rawValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //returning to first tab with an updated currentdish
        guard let dishListVM = dishListVM else {return}
        NotificationCenter.default.post(name: updateNotification, object: dishListVM.dishAtIndex(at: indexPath.row), userInfo: ["dishVM" : dishListVM.dishAtIndex(at: indexPath.row)])
        let tabC = tabBarController as? CustomTabBarController
        tabC?.prevSelectedTag = 0 //property is from custom tabBar for animataion control
        tabC?.selectedIndex = 0 //returning to first tab
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { //deleting row by slide
        guard let dishListVM = dishListVM else {return}
        NotificationCenter.default.post(name: deleteNotification, object: dishListVM.dishAtIndex(at: indexPath.row), userInfo: ["dishVM" : dishListVM.dishAtIndex(at: indexPath.row)])
        
        if dishListVM.searchState == .notSearching {
            dishListVM.dishList.remove(at: indexPath.row)
        } else { //if searchState == .searching
            
            for i in 0...dishListVM.dishList.count-1 {
                if dishListVM.dishList[i].dish.objectID == dishListVM.searchList[indexPath.row].dish.objectID {
                    guard !dishListVM.searchListIsEmpty else {
                        return
                    }
                    dishListVM.searchList.remove(at: indexPath.row)
                    dishListVM.dishList.remove(at: i)
                    break
                }
            }
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

//MARK: SEARCH BAR
extension BookController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {//when letters change in textfield
        guard let dishListVM = dishListVM else {return}
        dishListVM.searchText = searchText
        dishListVM.filterForSearch(text: searchText)
        tableView.reloadData()
        sortButton.isEnabled = dishListVM.sortIsEnabled
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        dishListVM?.searchText = ""
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setTapWallController(isHidden: false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        setTapWallController(isHidden: true)
    }
}

extension BookController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension BookController {
    //MARK: ALERTS
    func createSortActionSheet() {
        let actionSheet = UIAlertController(title: "Sort by:", message: "Choose your sort order", preferredStyle: .actionSheet)
        actionSheetiPadUpdate(actionSheet: actionSheet)
        
        let firstAction = UIAlertAction(title: SortType.alphabetic.rawValue, style: .default, handler: {[weak self]_ in
            
            guard let self = self, let dishListVM = self.dishListVM else {return}
            dishListVM.setSortFromInt(input: .alphabetic)
            self.saveContext()
            dishListVM.sortDishes()
            self.tableView.reloadData()
            
        })
        
        let secondAction = UIAlertAction(title: SortType.oldestToNewest.rawValue, style: .default, handler: {[weak self]_ in
            guard let self = self, let dishListVM = self.dishListVM else {return}
            dishListVM.setSortFromInt(input: .oldestToNewest)
            self.saveContext()
            dishListVM.sortDishes()
            self.tableView.reloadData()
        })
        let thirdAction = UIAlertAction(title: SortType.newestToOldest.rawValue, style: .default, handler: {[weak self]_ in
            guard let self = self, let dishListVM = self.dishListVM else {return}
            dishListVM.setSortFromInt(input: .newestToOldest)
            self.saveContext()
            dishListVM.sortDishes()
            
            self.tableView.reloadData()
        })
        
        let fourthAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(firstAction)
        actionSheet.addAction(secondAction)
        actionSheet.addAction(thirdAction)
        actionSheet.addAction(fourthAction)
        
        present(actionSheet, animated: true)
    }
}

extension BookController {
    //MARK: CORE DATA SAVE
    func saveContext() {
        guard let context = context else {return}
        do {
            try context.save()
        }
        catch {
            print("core add error")
            print(error.localizedDescription)
        }
    }
}
