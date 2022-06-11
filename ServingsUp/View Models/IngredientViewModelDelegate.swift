//
//  IngredientViewModelDelegate.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/14/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

protocol IngredientViewModelDelegate {
    func didGetError(errorType: BasicError, fieldTag: Int)
}
