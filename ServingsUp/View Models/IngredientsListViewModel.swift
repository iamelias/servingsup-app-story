//
//  IngredientsListViewModel.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/12/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

class IngredientListViewModel {
    
    var ingredientList: [IngredientViewModel] = []
    
    func numOfSections() -> Int {
        return 1
    }
    
    func numOfRowsInSection() -> Int {
        return ingredientList.count
    }
    
    func ingredientAtIndex(index: Int) -> IngredientViewModel {
        return ingredientList[index]
    }
    
    func appendIngredient(ingredientVM: IngredientViewModel) {
        ingredientList.append(ingredientVM)
    }
    
    func removeIngredient(ingredientVM: IngredientViewModel) {
        ingredientList = ingredientList.filter{$0.ingredient != ingredientVM.ingredient}
    }
    
    func printIngredientVMs() {
        for i in ingredientList {
            print("\n")
            print(i.name ?? "Empty String")
            print(i.ingredient.creationDate ?? "Date is Nil")
        }
    }
    
    func sortIngredientVMs() { //ingredients are sorted by creation date earliest(top) to latest(bottom)
        ingredientList.sort{ $0.ingredient.creationDate ?? Date() < $1.ingredient.creationDate ?? Date()}    }
}

