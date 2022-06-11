//
//  Constants.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/8/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

var massUnitArray: [String] = ["","oz","mg","g","kg","lb"] //tag 1
var volumeUnitArray: [String] = ["","oz","tsp","tbsp","cup","pt","qt","mL","L","gal"] //tag 2

enum FormatError: Error {
    case blankError
    case blankNameOrAmount
    case nameTooLongError
    case nameAlreadyExists
}

enum UnitType: String {
    case mass = "mass"
    case volume = "volume"
}

enum AppItem: String {
    case image
    case dish
    case ingredient
    case dishList = "dishes"
    case ingredientList = "ingredients"
}

enum Result {
    case success
    case failure
}

let addNotification = Notification.Name(rawValue: "add.notification")
var deleteNotification = Notification.Name(rawValue: "delete.notification")
var updateNotification = Notification.Name(rawValue: "update.current.notification")

let sortDictionary: [Int:SortType] = [0:.oldestToNewest,1:.newestToOldest,3:.alphabetic]


