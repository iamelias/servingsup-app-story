//
//  DishListViewModel.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/8/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

class DishListViewModel {
    var dishList: [DishViewModel] = []
    var searchList: [DishViewModel] = []
    
    var currentDish: DishViewModel? {
        for i in dishList {
            if i.isCurrentDish == true {
                return i
            }
        }
        return nil
    }
    
    enum SearchState {
        case notSearching
        case searching
    }
    
    var mySort: CoreSortOption?
    
    var sortOption: SortType {
        guard let mySort = mySort?.sort else {
            return .oldestToNewest
        }
        switch mySort {
        case 0: return .oldestToNewest
        case 1: return .newestToOldest
        case 2: return .alphabetic
        default: return .oldestToNewest
        }
    }
    
    var searchState: SearchState {
        if let searchText = searchText, !searchText.isEmpty {
            return .searching
        } else {
            return .notSearching
        }
    }
    
    var sortIsEnabled: Bool {
        return searchState == .notSearching
    }
    
    var correctArray: [DishViewModel] {
        return searchState == .notSearching ? dishList:searchList
    }
    
    var isEmpty: Bool {
        return self.dishList.isEmpty
    }
    
    var searchText: String? = ""
    
    var searchListIsEmpty: Bool {
        return searchList.isEmpty
    }
    
    var dishCount: Int {
        return self.dishList.count
    }
    
    var sortType: SortType = .oldestToNewest
    
    public init(dishes: [CoreDish]) {
        createDishVMs(dishes: dishes)
    }
    
    func setSortType(sortType: SortType) {
        self.sortType = sortType
    }
    
    func setMySort(sort: CoreSortOption) {
        self.mySort = sort
    }
    
    func setSortFromInt(input: SortType) {
        switch input {
        case .oldestToNewest: self.mySort?.sort = 0
        case .newestToOldest: self.mySort?.sort = 1
        case .alphabetic: self.mySort?.sort = 2
        }
    }
    
    func sortDishes() {
        switch self.sortOption {
        case .alphabetic: dishList.sort {$0.dishName.lowercased() < $1.dishName.lowercased()}
        case .oldestToNewest: dishList.sort {$0.creationDate < $1.creationDate}
        case .newestToOldest: dishList.sort {$0.creationDate > $1.creationDate}
        }
    }
    
    func checkDishAlreadyExists(name: String) throws {
        for i in dishList {
            if name == i.dishName {
                throw FormatError.nameAlreadyExists
            }
        }
    }
    
    func numOfSections() -> Int {
        return 1
    }
    
    func numOfRowsInSection() -> Int {
        return searchState == .notSearching ? self.dishList.count:self.searchList.count
    }
    
    func dishAtIndex(at index: Int) -> DishViewModel{
        let dish = searchState == .notSearching ? self.dishList[index]:self.searchList[index]
        return dish
    }
    
    func createDishVMs(dishes: [CoreDish]) {
        for i in dishes {
            let newDishVM = DishViewModel(dish: i)
            self.dishList.append(newDishVM)
        }
    }
    
    func createNewDishVM(dish: CoreDish, name: String? = nil) {
        dishList = dishList.filter{$0.isSaved}
        let newDishVM = DishViewModel(dish: dish)
        if name != nil {
            newDishVM.setName(name: name ?? "")
        }
        dishList.append(newDishVM)
        setCurrentDish(dishVM: newDishVM)
    }
    
    func appendDishViewModel(dishVM: DishViewModel) {
        dishList.append(dishVM)
    }
    
    func filterUntitleds() {
        dishList = dishList.filter{$0.isSaved == true}
       // print(dishList)
    }
    
    func filterNotSaved() {
        dishList = dishList.filter{$0.isSaved}
    }
    
    func filterForSearch(text: String) {
        guard searchState == .searching else {return}
        searchList = dishList.filter({$0.dishName.lowercased().prefix(text.count) == text.lowercased()})
    }
    
    func filterDishes(selectedDish: DishViewModel?) {
        guard let selectedDish = selectedDish else {return}
        dishList = dishList.filter{$0.dish.objectID != selectedDish.dish.objectID}
    }
    
    func setCurrentDish(dishVM: DishViewModel) {
        for i in dishList {
            if i.isCurrentDish == true {
                i.setIsCurrentDish(setter: false)
            }
            if i.dish == dishVM.dish {
                i.setIsCurrentDish(setter: true)
                i.setLastEditDate()
            }
        }
    }
    
    func getLastVM() -> DishViewModel? {
        return self.dishList.last
    }
}
