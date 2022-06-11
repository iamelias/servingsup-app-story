//
//  DishViewModel.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/8/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

class DishViewModel {
    enum State {
        case new
        case custom
    }
    
    enum SavedStatus {
        case saved
        case unSaved
    }
    
    var dish: CoreDish
    var delegate: DishViewModelDelegate?
    
    var prefersLargeTitle: Bool {
        return self.dishName.count > 6
    }
    
    var isSaved: Bool {
        return dishName != "Untitled"
    }
    
    var currentState: State {
        if dishName == "Untitled" && editedServings == "1" && self.ingredientCount <= 0 {
            return .new
        } else {
            return .custom
        }
    }
    
    var ingredientCount: Int {
        guard let ingredientCount = dish.ingredients?.count else {
            return 0
        }
        return ingredientCount
    }
    
    var isIngredientsEmpty: Bool {
        return ingredientCount == 0
    }
    
    var myUuid: UUID? {
        return self.dish.myUUID
    }
    
    var dishFolderPath: URL? { //gives path to dish folder in document directory
        guard let myUuid = self.myUuid else {
            return nil
        }
        let fm = FileManager.default
        let directoryURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        if let path = directoryURL {
            let newFolder = path.appendingPathComponent("photos").appendingPathComponent("\(myUuid)")
            return newFolder
        } else {
            return nil
        }
    }
    
    var thumbNailPath: URL? {
        guard let myUuid = self.myUuid else {
            return nil
        }
        let fm = FileManager.default
        let directoryURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first
        if let path = directoryURL {
            let newFolder = path.appendingPathComponent("photos").appendingPathComponent("\(myUuid)thumb")
            return newFolder
        } else {
            return nil
        }
    }
    
    var documentsDirectoryPath: URL? {
        let fm = FileManager.default
        guard let path = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        return path
    }
    
    var dishImage: UIImage? {return nil
    }
    
    var isCustom: Bool {
        return currentState == .custom
    }
    
    var ingredientsList: NSSet? {
        return self.dish.ingredients
    }
    
    var ingredientListVMs: IngredientListViewModel = IngredientListViewModel() //********
    
    var editedServings: String {
        return "\(self.dish.editedServings)"
    }
    var dishName: String {
        return self.dish.name ?? ""
    }
    var creationDate:Date {
        return self.dish.creationDate ?? Date()
    }
    
    var lastEditedDate: Date {
        return self.dish.lastEditedDate ?? Date()
    }
    
    var image: UIImage? {
        if let image = self.dish.image {
            return UIImage(data: image)
        } else {
            return nil
        }
    }
    
    var thumbNailImage: UIImage? {
        if let image = self.dish.thumbnailImage {
            return UIImage(data: image)
        } else {
            return nil
        }
    }
    
    var bookViewImage: UIImage? {
        if let image = image {
            return image
        } else {
            return UIImage(named: "fullCamera1" )
        }
    }
    
    var bookImageSize: CGSize {
        return CGSize(width: 90.0, height: 90.0)
    }
    
    var imageData: Data? {
        return self.dish.image
    }
    
    var thumbNailImageData: Data? {
        return self.dish.image
    }
    
    var images: [UIImage?]? {
        return nil
    }
    
    var imagePresent: Bool {
        return image != nil
    }
    
    var isCurrentDish: Bool {
        return self.dish.isCurrentDish
    }
    
    var lastAccessed: Bool = false
    
    public init(dish: CoreDish) {
        self.dish = dish
        self.dish.creationDate = Date()
        createIngredientVMs()
    }
    
    func setIsCurrentDish(setter: Bool) {
        self.dish.isCurrentDish = setter
        self.dish.lastEditedDate = Date()
    }
    
    func setName(name: String) {
        if let error = Util.verifyTextHelper(textData: name) {
            delegate?.didGetError(errorType: error)
            return
        }
        if dishName == "Untitled" {
            self.dish.creationDate = Date()
        }
        dish.name = name
    }
    
    func setStepperValue(stepperValue: Double ) {
        self.dish.stepperValue = stepperValue
        self.dish.editedServings = Int16(stepperValue)
    }
    
    func createIngredientVMs() {
        guard let ingredients = self.dish.ingredients else {return}
        for i in ingredients {
            let ingredientVM = IngredientViewModel(ingredient: i as! CoreIngredient)
            ingredientListVMs.appendIngredient(ingredientVM: ingredientVM)
        }
    }
    
    func setImage(image: UIImage) {
        self.dish.image = image.pngData()
        if let thumbNailImage = image.resizeImage()?.pngData() {
            self.dish.thumbnailImage = thumbNailImage
        } else {
            print("Error")
        }
    }
    
    func removeImage() {
        self.dish.image = nil
        self.dish.thumbnailImage = nil
    }
    
    func setLastEditDate() {
        dish.lastEditedDate = Date()
    }
    
    func incrementServings() {
        self.dish.stepperValue += 1.0
        self.dish.editedServings += 1
    }
    
    func decrementServings() {
        self.dish.stepperValue -= 1.0
        self.dish.editedServings -= 1
    }
    
    func checkNameCount() -> Int {
        return dishName.count
    }
    
    func sortIngredients() {
        ingredientListVMs.sortIngredientVMs()
    }
    
    func resetView() {
        dish.name = ""
        dish.editedServings = 1
        dish.creationDate = Date()
        dish.lastEditedDate = dish.creationDate
    }
    
    func getStepperDouble() -> Double {
        return Double(self.dish.editedServings)
    }
    
    func addIngredient(ingredientVM: IngredientViewModel) {
        ingredientVM.setCreationDate()
        dish.addToIngredients(ingredientVM.ingredient)
        let newIngredientVM = IngredientViewModel(ingredient: ingredientVM.ingredient)
        ingredientListVMs.appendIngredient(ingredientVM: newIngredientVM)
    }
    
    func multiplyIngredients() {
        for i in ingredientListVMs.ingredientList {
            let servings = Double(editedServings)
            guard let servings = servings else {return}
            i.setAmount(amount: "\(i.singleServingAmount * servings)")
        }
    }
    
    func deleteIngredient(index: Int) {
        dish.removeFromIngredients(ingredientListVMs.ingredientAtIndex(index: index).ingredient) //removing from CoreDish
        ingredientListVMs.removeIngredient(ingredientVM: ingredientListVMs.ingredientAtIndex(index: index)) //removing from ingredientListVM
    }
    
    func createDirectory() { //saves dish details to document directory
        guard let dishFolderPath = dishFolderPath, let thumbNailPath = thumbNailPath, let imageData = self.imageData, let thumbNailImage = thumbNailImageData else {return}
        let fm = FileManager.default
        do { //creating directory for dish using filePath
            try fm.createDirectory(at: dishFolderPath, withIntermediateDirectories: true, attributes: [.creationDate: Date()])
            fm.createFile(atPath: dishFolderPath.path, contents: imageData, attributes: [.creationDate: Date()])
            fm.createFile(atPath: thumbNailPath.path, contents: thumbNailImage)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func retrieveFile() {
        let fm = FileManager.default
        guard let dishFolderPath = dishFolderPath, let thumbNailPath = thumbNailPath else {return}
        let data = fm.contents(atPath: dishFolderPath.path)
        let dataThumb = fm.contents(atPath: thumbNailPath.path)
        if let data = data, let dataThumb = dataThumb {
            self.dish.image = data
            self.dish.thumbnailImage = dataThumb
        } else {}
    }
    
    func deleteFile() {
        let fm = FileManager.default
        guard let dishFolderPath = dishFolderPath, let thumbNailPath = thumbNailPath else {return}
        do {
            try fm.removeItem(at: dishFolderPath)
            try fm.removeItem(at: thumbNailPath)
        } catch {
            print(error.localizedDescription)
        }
    }
}
