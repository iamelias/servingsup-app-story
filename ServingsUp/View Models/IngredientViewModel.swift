//
//  NewIngredientViewModel.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/8/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

class IngredientViewModel {
    
    var ingredient: CoreIngredient
    
    var delegate: IngredientViewModelDelegate?
    
    enum State {
        case blank
        case custom
    }
    
    enum UpdateState: String {
        case new = "Add"
        case update = "Update"
    }
    
    var currentState: State {
        isBlank ? .blank : .custom
    }
    
    var updateState: UpdateState = .new
    
    var name: String? {
            return self.ingredient.name
    }
    
    var nameEmpty: Bool {
        return ingredient.name == ""
    }
    
    var errorExists: Bool = false
    
    var isBlank: Bool {
        if name == "" && servings == "1" {
            return true
        } else {
            return false
        }
    }
    
    var servings: String {
            return "\(Int(self.ingredient.servings))"
    }
    
    var stepperServingsValue: Double {
        return Double(self.ingredient.servings)
    }
    
    var amount:String? {
        if currentState == .blank {
            return ""
        } else {
            let roundedAmount = String(format: "%.3f", self.ingredient.amount) //3 decimal places
            let outputAmount = Util.removeTrailingZeros(input: roundedAmount)
        return "\(outputAmount)"
          }
    }
    
    var unit:String {
        if unitType == 0 {
            return massUnitArray[unitTypeIndex]
        }
        else {
            return volumeUnitArray[unitTypeIndex]
        }
    }
    
    var creationDate: Date {
        return ingredient.creationDate ?? Date()
    }
    
    var unitTypeIndex: Int { //index of unit picker
        return Int(self.ingredient.unit)
    }
    
    var unitType: Int { //unitype: 0 = mass, unitype: 1 = volume
        return Int(self.ingredient.unitType)
    }
    
    var cellDisplayAmount: String {
        let roundedAmount = String(format: "%.3f", self.ingredient.amount)
        let outputAmount = Util.removeTrailingZeros(input: roundedAmount)
        return "\(outputAmount) \(self.unit)"
    }
    
    var modifiedIngredient:String {
            return self.ingredient.modifiedIngredient ?? ""
    }
    
    var singleServingAmount: Double { 
        return self.ingredient.singleAmount
    }
    
    public init(ingredient: CoreIngredient) {
        self.ingredient = ingredient
    }
    
    func setName(name: String) {
        if let error = Util.verifyTextHelper(textData: name) {
            errorExists = true
            ingredient.name = ""
            delegate?.didGetError(errorType: error, fieldTag: 1)
        } else {
        errorExists = false
        ingredient.name = name
        }
    }
    
    func setAmount(amount: String) {
        if let error = Util.verifyTextHelper(textData: amount) {
            errorExists = true
            delegate?.didGetError(errorType: error, fieldTag: 2)
        } else {
        errorExists = false
        ingredient.amount = Double(amount) ?? 0.0 / stepperServingsValue
        }
    }
    
    func setUnit(unit: Int) {
        ingredient.unit = Int16(unit) //unit of picker value
    }
    
    func setServings(servings: Double) {
        ingredient.servings = Int32(servings)
    }
    
    func setSingleServingAmount() {
        let doubleAmount = Double(amount ?? "0.0") ?? 0.0
        ingredient.singleAmount = doubleAmount/stepperServingsValue
    }
    
    func setUnitType(segmentIndex: Int) {
        ingredient.unitType = Int16(segmentIndex)
    }
    
    func setCreationDate() {
        ingredient.creationDate = Date()
    }
    
    func getUnitTypesIndex() -> Int { //returns the unit from the respective unit array
        if unitType == 0 {
            return massUnitArray.firstIndex(of: self.unit) ?? 0
        } else {
            return volumeUnitArray.firstIndex(of: self.unit) ?? 0
        }
    }
}
