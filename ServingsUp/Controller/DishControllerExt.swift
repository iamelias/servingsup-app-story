//
//  DishControllerExt.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/13/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

extension DishController {
    
    //MARK: ALERT METHODS AND HELPER METHODS
    func preSavedAlert() { //When dish is untitled
        guard let currentDish = dishListVM?.currentDish else {return}
        let alert = UIAlertController(title: "New Dish", message: "Enter the name of your dish", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(customTextField) in
            customTextField.autocapitalizationType = .sentences
            customTextField.autocorrectionType = .no
        })
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {[weak self]_ in
            guard let self=self, let textData = alert.textFields?[0].text else{return}
            
            let thisError = self.runErrorCheck(textData: textData, alertHistoryAppend1: self.runPreSavedAlert, alertHistoryAppend2: self.runPreSavedAlert)
            guard thisError == nil else{return}
            currentDish.setName(name: textData)
            self.navigationConfig()
            self.saveContext()
            self.outletViewConfig()
        })
        alert.addAction(saveAction)
        present(alert,animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    
    func postSavedAlert() { //when dish is already titled
        let alert = UIAlertController(title: "Create Dish", message: "Rename or Create New", preferredStyle: .alert)
        alertHistory.append(runPostSavedAlert)
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: {[weak self]_ in
            guard let self = self else{return}
            self.renameDishAlert()
        })
        let newAction = UIAlertAction(title: "New", style: .default, handler: {[weak self]_ in
            guard let self=self else{return}
            self.addNewDishAlert()
        })
        
        alert.addAction(renameAction)
        alert.addAction(newAction)
        present(alert,animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    
    func renameDishAlert() {
        guard let currentDish = dishListVM?.currentDish else {return}
        let alert = UIAlertController(title: "Rename Dish", message: "Enter a new name for this dish", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(customTextField) in
            customTextField.autocapitalizationType = .sentences
            customTextField.autocorrectionType = .no
        })
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: {[weak self]_ in
            guard let self = self, let textData = alert.textFields?[0].text else{return}
            
            let thisError = self.runErrorCheck(textData: textData, alertHistoryAppend1: self.runRenameAlert, alertHistoryAppend2: self.runRenameAlert)
            guard thisError == nil else {return}
            currentDish.setName(name: textData)
            self.refreshViewConfig()
        })
        let backAction = UIAlertAction(title: "Back", style: .cancel, handler: { [weak self]_ in
            guard let self = self else {return}
            guard let closure = self.alertHistory.popLast() else {
                return
            }
            closure() //running previous alert
        })
        alert.addAction(renameAction)
        alert.addAction(backAction)
        present(alert,animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    
    func addNewDishAlert() {
        let alert = UIAlertController(title: "Add New Dish", message: "Enter the name of your new dish", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(customTextField) in
            customTextField.autocapitalizationType = .sentences
            customTextField.autocorrectionType = .no
        })
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {[weak self]_ in
            guard let self = self, let textData = alert.textFields?[0].text else {return}
            
            let thisError = self.runErrorCheck(textData: textData, alertHistoryAppend1: self.addNewDishAlert, alertHistoryAppend2: self.runNewDishAlert)
            guard thisError == nil else{return}
            self.createNewDishHelper(textData: textData)
        })
        
        let backAction = UIAlertAction(title: "Back", style: .cancel, handler: {[weak self]_ in
            guard let self = self else {return}
            let closure = self.alertHistory.popLast()
            guard let closure = closure else {return}
            closure()
        })
        
        alert.addAction(addAction)
        alert.addAction(backAction)
        present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    
    func createNewDishHelper(textData: String) {
        guard let context = context, let dishListVM = dishListVM else {return}
        
        let newDish = CoreDish(context: context)
        newDish.myUUID = UUID()
        dishListVM.createNewDishVM(dish: newDish, name: textData)
        self.saveContext()
        refreshViewConfig()
        dishImageView.image = dishListVM.currentDish?.image
        tableView.reloadData()
    }
    
    func formatErrorAlert(error: BasicError) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let backAction = UIAlertAction(title: "Back", style: .default, handler: {[weak self]_ in
            guard let self = self else {return}
            let returnClosure = self.alertHistory.popLast()
            if let returnClosure = returnClosure {
                returnClosure()
                return
            } else {return}
        })
        alert.addAction(backAction)
        present(alert,animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    
    func simpleErrorAlert(item: AppItem) {
        let alert = UIAlertController(title: "Error", message: "There is an issue processing this \(item.rawValue). ", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: {[weak self]_ in
            guard let self = self, self.activityIndicator.isAnimating else{return}
              //  self.setToggleActivityIndicator(isOn: false)
        })
        alert.addAction(closeAction)
        present(alert, animated: true)
    }
    
    func runErrorCheck(textData: String, alertHistoryAppend1: (()->())?, alertHistoryAppend2:(()->())?) -> BasicError? {
        let error = Util.verifyTextHelper(textData: textData) //verifying text format
        if let error = error {
            if alertHistoryAppend1 != nil {
                alertHistory.append(alertHistoryAppend1!)
            }
            Util.hapticError()
            self.formatErrorAlert(error: error)
            return error
        }
        if let dishListVM = self.dishListVM {
            do {
                try dishListVM.checkDishAlreadyExists(name: textData)
            }
            catch {
                if alertHistoryAppend2 != nil {
                    self.alertHistory.append(alertHistoryAppend2!)
                }
                Util.hapticError()
                let error = BasicError(errorType: .nameAlreadyExists, title: "Name Already Exists", message: "This name already exists. Please choose a different name")
                self.formatErrorAlert(error: error)
                return error
            }
        }
        return nil
    }
    
    func runDeleteFileControlHelper() {
        guard let dishListVM = dishListVM,let context = self.context, let currentDish = dishListVM.currentDish else{return}
        currentDish.deleteFile() //removing saved images from FileManager
        dishListVM.filterDishes(selectedDish: currentDish)
        context.delete(currentDish.dish)
        for i in dishListVM.dishList {
            if !i.isCurrentDish && !i.isSaved {
                context.delete(i.dish)
            }
        }
        dishListVM.filterUntitleds()
    }
    
    func runCreateBlankDishHelper() {
        guard let dishListVM = dishListVM,let context = self.context else{return}
        let blankDish = CoreDish(context: context)
        blankDish.myUUID = UUID()
        dishListVM.createNewDishVM(dish: blankDish)
        dishListVM.currentDish?.removeImage()
    }
    
    func refreshViewConfig() {
        self.navigationConfig()
        self.outletViewConfig()
    }
    
    func deleteAlert() {
        let alert = UIAlertController(title: "Delete Dish", message: "Are you sure you want to permanently delete this dish?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self]_ in
            guard let self = self, let dishListVM = self.dishListVM  else {return}
            self.runDeleteFileControlHelper()
            self.runCreateBlankDishHelper()
            self.saveContext()
            self.refreshViewConfig()
            self.dishImageView.image = dishListVM.currentDish?.image
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert,animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertBackgroundTapped)))
        })
    }
    @objc func alertBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func cameraActionSheet() {
        let actionSheet = UIAlertController(title: "Add Image", message: "Take a photo of your dish using your camera, or select a photo from your photo library", preferredStyle: .actionSheet)
        
        if UIDevice.current.userInterfaceIdiom == .pad { //to prevent crash on iPad
            actionSheetiPadUpdate(actionSheet: actionSheet)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {[weak self]_ in
            guard let self = self else {return}
            self.present(self.imagePicker,animated: true,completion: nil)
        })
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: {[weak self]_ in
            guard let self = self else{return}
            self.photoLibrayDidSelect()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
}

extension DishController: DishViewModelDelegate {
    func didGetError(errorType: BasicError) {
        formatErrorAlert(error: errorType)
    }
}


