//
//  AddIngredientController.swift
//  ServingsUp
//
//  Created by Elias Hall on 1/26/20.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddIngredientController: UIViewController {
    
    @IBOutlet weak var ingredientNameTextfield: UITextField!
    @IBOutlet weak var servingsNumLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var massVolSegmentedControl: UISegmentedControl!
    @IBOutlet weak var servingsStepper: UIStepper!
    @IBOutlet weak var unitPicker: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    
    var delegate: AddIngredientControllerDelegate?
    var context: NSManagedObjectContext?
    var ingredientVM: IngredientViewModel? //nil == "new", not nil == "update"
    
    //MARK: VIEW LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        createIngredient()
        setDelegatesDataSources()
        outletConfig()
        toolbarConfig()
        textFieldConfig()
        setGestureRecognizers()
    }
    
    //MARK: IBACTIONS
    @IBAction func addButtonDidTouch(_ sender: UIButton) {
        guard let delegate = delegate, let ingredientVM = ingredientVM else {
            return
        }
        ingredientVM.setName(name: ingredientNameTextfield.text ?? "")
        guard !ingredientVM.errorExists else {return}
        ingredientVM.setAmount(amount: amountTextField.text ?? "")
        guard !ingredientVM.errorExists else {return}
        ingredientVM.setUnit(unit: unitPicker.selectedRow(inComponent: 0)) //index of picker
        ingredientVM.setUnitType(segmentIndex: massVolSegmentedControl.selectedSegmentIndex) //segment index: 0 = mass, 1 = volume
        ingredientVM.setServings(servings: servingsStepper.value)
        ingredientVM.setSingleServingAmount()
        delegate.didAddIngredient(ingredientVM: ingredientVM)
        dismiss(animated: true)
    }
    @IBAction func cancelButtonDidTouch(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func stepperDidTouch(_ sender: UIStepper) {
        guard let ingredientVM = ingredientVM else {
            return
        }
        ingredientVM.setServings(servings: sender.value)
        servingsNumLabel.text = ingredientVM.servings
    }
    @IBAction func segmentedControlDidTouch(_ sender: UISegmentedControl) {
        guard let ingredientVM = ingredientVM else {
            return
        }
        view.endEditing(true)
        ingredientVM.setUnitType(segmentIndex: sender.selectedSegmentIndex)
        unitPicker.reloadComponent(0)
    }
    
    func setGestureRecognizers() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddIngredientController.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        let swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AddIngredientController.dismissKeyboard))
        view.addGestureRecognizer(swipeGesture)
    }
    
    func setDelegatesDataSources() {
        unitPicker.delegate = self
        unitPicker.dataSource = self
        ingredientNameTextfield.delegate = self
        amountTextField.delegate = self
    }
    
    func outletConfig() {
        guard let context = context else {
            return
        }
        guard let ingredientVM = ingredientVM else {
            /*
             If this is a new ingredient, initializing a new CoreIngredient and ViewModel before connections
             */
            let newIngredient = CoreIngredient(context: context)
            ingredientVM = IngredientViewModel(ingredient: newIngredient)
            outletConfig()
            return
        }
        
        ingredientNameTextfield.text = ingredientVM.name
        servingsStepper.value = ingredientVM.stepperServingsValue
        servingsNumLabel.text = ingredientVM.servings
        amountTextField.text = ingredientVM.amount
        amountTextField.placeholder = "0.0"
        massVolSegmentedControl.selectedSegmentIndex = ingredientVM.unitType
        if ingredientVM.updateState == .new {
            unitPicker.selectRow(3, inComponent: 0, animated: false)
        } else {
            unitPicker.selectRow(ingredientVM.unitTypeIndex, inComponent: 0, animated: false)
        }
        addButton.setTitle(ingredientVM.updateState.rawValue, for: .normal)
    }
    
    func textFieldConfig() {
        ingredientNameTextfield.keyboardType = .default
        amountTextField.keyboardType = .decimalPad
    }
    func toolbarConfig() { //adding a toolbar with "done" at top of keyboard for keyboard dismissal
        let numPadToolbar: UIToolbar = UIToolbar()
        numPadToolbar.barStyle = UIBarStyle.default
        numPadToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.resignKeyboard))
        ]
        numPadToolbar.sizeToFit()
        amountTextField.inputAccessoryView = numPadToolbar
    }
    
    func createIngredient() {
        guard let context = context else {
            return
        }
        if ingredientVM == nil {
            let ingredient = CoreIngredient(context: context)
            ingredientVM = IngredientViewModel(ingredient: ingredient)
        }
        ingredientVM?.delegate = self
    }
    
    //MARK: ADDITIONAL METHODS
    @objc func resignKeyboard () { //dismiss for "'done' toolbar"
        amountTextField.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() { //gesture action dismiss
        view.endEditing(true)
    }
}

//MARK: DELEGATE METHODS
extension AddIngredientController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    func shake() { //shake animation for textfield alert error
        let animation = CABasicAnimation(keyPath: "position")
        animation.repeatCount = 2
        animation.duration = 0.05
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 4.0, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 4.0, y: self.center.y)
        layer.add(animation, forKey: "position")
    }
}

//MARK: PICKERVIEW METHODS
extension AddIngredientController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let ingredientVM = ingredientVM else {
            return 0
        }
        return ingredientVM.unitType == 0 ? massUnitArray.count:volumeUnitArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let ingredientVM = ingredientVM else {
            return nil
        }
        return ingredientVM.unitType == 0 ? massUnitArray[row]:volumeUnitArray[row]
    }
}

