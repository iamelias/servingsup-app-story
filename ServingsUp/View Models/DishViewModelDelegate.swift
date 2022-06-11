//
//  DishViewModelDelegate.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/13/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

protocol DishViewModelDelegate {
    func didGetError(errorType: BasicError)
}
