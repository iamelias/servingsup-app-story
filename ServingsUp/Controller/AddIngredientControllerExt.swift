//
//  AddIngredientControllerExt.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/14/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

extension AddIngredientController {
    
    func formatErrorAlert(error: BasicError) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension AddIngredientController: IngredientViewModelDelegate { 
    func didGetError(errorType: BasicError, fieldTag: Int) { //fieldTag indicates which textfield has error
        Util.hapticError()
        fieldTag == 1 ? ingredientNameTextfield.shake():amountTextField.shake()
        formatErrorAlert(error: errorType)
    }
}
