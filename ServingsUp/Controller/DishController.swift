//
//  DishController.swift
//  ServingsUp
//
//  Created by Elias Hall on 1/26/20.
//  Updated 6/9/22
//  Copyright © 2022 Elias Hall. All rights reserved.

import UIKit
import Foundation
import CoreData
import PhotosUI

class DishController: UIViewController, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var servingsNumLabel: UILabel!
    @IBOutlet weak var addIngredientButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var servingsStepper: UIStepper!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var emptyTextView: UITextView!
    @IBOutlet weak var saladBowlImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    let imagePicker = UIImagePickerController()
    var dishes: [CoreDish] = [] //stores dishes from core data, stored by creationdate
    var ingredients: [CoreIngredient] = [] //stores ingredients from core data
    var dishListVM: DishListViewModel? //all dishes
    var ingredientListVM: IngredientListViewModel? //all ingredients belonging to currentDishVM
    var firstRun: Bool = false
    lazy var runNewDishAlert: ()->() = {}
    lazy var runRenameAlert: ()->() = {}
    lazy var runPreSavedAlert: ()->() = {}
    lazy var runPostSavedAlert: ()->() = {}
    
    var alertHistory:[()->()] = []
        
    //MARK: VIEW LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveCoreDishes() // getting all dishes from core data
        dishListVM = DishListViewModel(dishes: self.dishes)
        setCurrentDish()
        setDelegatesDataSources()
        observerConfig()
        outletViewConfig() //connecting all iboutlets
        navigationConfig() //configuring nav items
        imagePickerConfig()
        textViewConfig()
        imageConfig()
        alertClosureConfig()
        setGestureRecognizers()
        saladBowlImgConfig()
        tableView.reloadData() //reloading to show ingredients
        checkFileManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isTranslucent = true
        activityIndicator.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if firstRun == false {
            tabBarController?.viewControllers?[1].view.layoutIfNeeded() //preloading second
            firstRun = true
        }
    }
    
    func checkFileManager() {
        let fm = FileManager.default
        guard let firstPath = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let path = firstPath.appendingPathComponent("photos")
        let contents = try? fm.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        if let contents = contents{
            print(contents.count)
            for i in contents {
                print(i.path)
            }
        }
    }
    
    //MARK: IBACTIONS
    @IBAction func saveButtonDidTouch(_ sender: UIBarButtonItem) {
        //calls alert to give dish a name
        //saves context and adds to dishlistvm
        guard let dishListVM = dishListVM, let dishVM = dishListVM.currentDish else {return}
        alertHistory.removeAll()
        dishVM.isSaved ? postSavedAlert():preSavedAlert() //isSaved means dishVM.dishName is not "Untitled"
    }
    @IBAction func addIngredientButtonDidTouch(_ sender: UIBarButtonItem) {
        //Uses instantiate view controller to call AddIngredientController passing data
        let selectedVC = storyboard?.instantiateViewController(withIdentifier: "AddIngredientController") as? AddIngredientController
        selectedVC?.modalTransitionStyle = .coverVertical
        selectedVC?.delegate = self
        selectedVC?.context = context
        guard let selectedVC = selectedVC else {return}
        present(selectedVC, animated: true, completion: nil)
    }
    
    @IBAction func addPhotoButtonDidTouch(_ sender: UIButton) {
        cameraActionSheet()
    }
    
    @IBAction func trashButtonDidTouch(_ sender: UIBarButtonItem) {
        deleteAlert()
        //calls delete dish alert and reinitializes dish with new blank dish object
    }
    
    @IBAction func stepperDidTouch(_ sender: UIStepper) {
        guard let currentDish = dishListVM?.currentDish, !currentDish.isIngredientsEmpty else {return}
        currentDish.setStepperValue(stepperValue: sender.value)
        servingsNumLabel.text = currentDish.editedServings
        currentDish.multiplyIngredients()
        saveContext()
        tableView.reloadData()
    }
    
    @objc func updateCurrentDish(notification: Notification) {
        guard let dishListVM = dishListVM else {return}
        
        guard let selectedDish = notification.userInfo?["dishVM"] as? DishViewModel else {
            print("nil in notification userInfo")
            return
        }
        dishListVM.setCurrentDish(dishVM: selectedDish)
        navigationConfig()
        outletViewConfig()
        dishImageView.image = selectedDish.thumbNailImage
        saveContext()
        DispatchQueue.main.async{ //running async to remove delay when tab is selected in other VC
            self.retrieveCoreDishes()
            self.tableView.reloadData()
        }
    }
    
    @objc func didTapImage(_ sender: UITapGestureRecognizer) {
        guard dishListVM?.currentDish?.image != nil else {return}
        self.performSegue(withIdentifier: "toDetailImage" , sender: self)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailImage" {
            let destinationVC = segue.destination as? ImageDetailViewController
            if let currentDish = dishListVM?.currentDish {
                destinationVC?.currentDishImage = currentDish.image
                destinationVC?.delegate = self
                let barBackButton = UIBarButtonItem()
                barBackButton.title = "Back"
                navigationItem.backBarButtonItem = barBackButton
            } else {
                print("Error")
            }
        }
    }
    
    @objc func deleteDish(notification: Notification) {
        guard let dishListVM = dishListVM, let context = context, let currentDish = dishListVM.currentDish else {
            return
        }
        
        guard let selectedDish = notification.userInfo?["dishVM"] as? DishViewModel else {
            print("nil in notification userInfo")
            return
        }
        if selectedDish.dish.objectID == currentDish.dish.objectID {
            dishListVM.filterUntitleds()
            currentDish.deleteFile()
            dishListVM.filterDishes(selectedDish: currentDish)
            context.delete(currentDish.dish)
            for i in dishListVM.dishList {
                if !i.isCurrentDish && !i.isSaved {
                    context.delete(i.dish)
                }
            }
            
            let blankDish = CoreDish(context: context)
            blankDish.myUUID = UUID()
            dishListVM.createNewDishVM(dish: blankDish, name: nil)
            saveContext()
            navigationConfig()
            outletViewConfig()
            tableView.reloadData()
        } else {
            dishListVM.filterUntitleds()
            selectedDish.deleteFile()
            dishListVM.filterDishes(selectedDish: selectedDish)
            context.delete(selectedDish.dish)
            saveContext()
        }
        dishImageView.image = dishListVM.currentDish?.thumbNailImage
    }
    
    func setDelegatesDataSources() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func alertClosureConfig() {
        runRenameAlert = {[weak self] in
            guard let self = self else {return}
            self.renameDishAlert()
        }
        runPreSavedAlert = {[weak self] in
            guard let self = self else {return}
            self.preSavedAlert()
        }
        runPostSavedAlert = {[weak self] in
            guard let self = self else {return}
            self.postSavedAlert()
        }
        
        runNewDishAlert = {[weak self] in
            guard let self = self else {return}
            self.addNewDishAlert()
        }
        
        runRenameAlert = {[weak self] in
            guard let self = self else {return}
            self.renameDishAlert()
        }
    }
    
    func setGestureRecognizers() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DishController.didTapImage)) //tap gesture
        dishImageView.isUserInteractionEnabled = true
        dishImageView.addGestureRecognizer(tapGesture)
    }
    
    func setToggleActivityIndicator(isOn: Bool, hapticHandler: (()->())? = nil) {
        activityIndicator.isHidden = !isOn
        activityIndicator.isHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        if let hapticHandler = hapticHandler {
            hapticHandler()
        }
    }
    
    func hapticControl(result: Result) {
        switch result {
        case .success: Util.hapticSuccess()
        case .failure: Util.hapticError()
        }
    }
    
    func setCurrentDish() {
        guard let dishListVM = dishListVM, let context = context else {return}
        
        if dishListVM.currentDish == nil {
            let newDish = CoreDish(context: context) //create new dish code
            newDish.myUUID = UUID()
            dishListVM.createNewDishVM(dish: newDish)
            saveContext()
        }
        dishListVM.currentDish?.sortIngredients()
        // dishListVM.currentDish?.printIngredients()
        dishListVM.currentDish?.retrieveFile() //setting uiimage
    }
    
    func alertHistoryConfig() {
        runPreSavedAlert = {[weak self] in
            guard let self = self else{return}
            self.preSavedAlert()
        }
        
        runPostSavedAlert = {[weak self] in
            guard let self = self else{return}
            self.postSavedAlert()
        }
        
        runRenameAlert = {[weak self] in
            guard let self = self else{return}
            self.runRenameAlert()
        }
    }
    
    func observerConfig() {
        NotificationCenter.default.addObserver(self, selector: #selector(DishController.deleteDish(notification: )), name: deleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DishController.updateCurrentDish(notification:)), name: updateNotification, object: nil)
    }
    
    func outletViewConfig() {
        guard let dishVM = dishListVM?.currentDish else {return}
        trashButton.isEnabled = dishVM.isCustom
        emptyTextView.isHidden = dishVM.ingredientCount > 0
        servingsNumLabel.text = dishVM.editedServings
        servingsStepper.value = dishVM.getStepperDouble()
    }
    
    func imagePickerConfig() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    func createNewDish()  {
        guard let context = context else {return}
        let newDish = CoreDish(context: context)
        newDish.myUUID = UUID()
        let newDishVM = DishViewModel(dish: newDish)
        dishListVM?.appendDishViewModel(dishVM: newDishVM)
        saveContext()
    }
    
    func textViewConfig() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineSpacing = 9.0
        
        let stringAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "placeholder color") ?? UIColor.lightGray,
            .font : UIFont.systemFont(ofSize: 17),
            .paragraphStyle : paragraphStyle
        ]
        
        let image1Attachment = NSTextAttachment() //mixing symbols with text...
        image1Attachment.image = UIImage(systemName: "plus")?.withTintColor(UIColor(named: "placeholder color") ?? UIColor.lightGray)
        let image1String = NSAttributedString(attachment: image1Attachment)
        let image2Attachment = NSTextAttachment()
        image2Attachment.image = UIImage(systemName: "square.and.pencil")?.withTintColor(UIColor(named: "placeholder color") ?? UIColor.lightGray)
        let image2String = NSAttributedString(attachment: image2Attachment)
        
        let fullString = NSMutableAttributedString(string: "Tap on the ", attributes: stringAttributes)
        fullString.append(image1String)
        fullString.append(NSAttributedString(string: " icon to add a new ingredient\nTap on the ", attributes: stringAttributes))
        fullString.append(image2String)
        fullString.append(NSAttributedString(string: " to give the dish a name", attributes: stringAttributes))
        
        emptyTextView.attributedText = fullString
    }
    
    func imageConfig() {
        guard let dishListVM = dishListVM else {return}
        
        if let currentDish = dishListVM.currentDish {
            currentDish.retrieveFile()
            dishImageView.image = currentDish.thumbNailImage
        } else {
            print("No current dish")
        }
    }
    
    func navigationConfig() {
        guard let dishListVM = dishListVM else {return}
        
        guard let dishVM = dishListVM.currentDish else {
            print("error dish current nav")
            return
        }
        navigationItem.title = dishVM.dishName
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func saladBowlImgConfig() {
        if let bowlColor = UIColor(named: "saladBowl color") {
            saladBowlImage.setImageColor(color: bowlColor)
        }
        saladBowlImage.transform = saladBowlImage.transform.rotated(by: CGFloat(0.025))
    }
}

//MARK: TABLEVIEW DELEGATE AND DATASOURCE METHODS
extension DishController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentDish = dishListVM?.currentDish else {
            return 0
        }
        
        if currentDish.ingredientListVMs.numOfRowsInSection() >= 3 {
            saladBowlImage.alpha = 0.03 //changing alpha so image doesn't interfere with clearness of text
        } else {
            saladBowlImage.alpha = 0.08
        }
        
        return currentDish.ingredientListVMs.numOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        
        guard let dishListVM = dishListVM else {
            return cell
        }
        
        var content = cell.defaultContentConfiguration()
        content.text = dishListVM.currentDish?.ingredientListVMs.ingredientAtIndex(index: indexPath.row).name
        content.secondaryText = dishListVM.currentDish?.ingredientListVMs.ingredientAtIndex(index: indexPath.row).cellDisplayAmount
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dishListVM = dishListVM, let currentDish = dishListVM.currentDish else {return}
        let selectedVC = storyboard?.instantiateViewController(withIdentifier: "AddIngredientController") as? AddIngredientController
        selectedVC?.modalTransitionStyle = .coverVertical
        selectedVC?.delegate = self
        selectedVC?.context = context
        selectedVC?.ingredientVM = dishListVM.currentDish?.ingredientListVMs.ingredientAtIndex(index: indexPath.row)
        selectedVC?.ingredientVM?.setServings(servings: Double(currentDish.editedServings) ?? 0)
        selectedVC?.ingredientVM?.updateState = .update
        guard let selectedVC = selectedVC else {return}
        present(selectedVC, animated: true, completion: {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        })
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let currentDish = dishListVM?.currentDish else {return}
        currentDish.deleteIngredient(index: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveContext()
        
        if currentDish.isIngredientsEmpty {
            emptyTextView.isHidden = false
        }
    }
}

//MARK: IIMAGEPICKERVIEW DELEGATE METHODS
extension DishController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        setToggleActivityIndicator(isOn: true)
        
        if let image = info[.editedImage] as? UIImage {
            guard let dishVM = dishListVM?.currentDish else {return}
            dishVM.deleteFile()
            dishVM.setImage(image: image)
            dishVM.createDirectory()
            dishVM.retrieveFile()
            dishImageView.image = dishVM.thumbNailImage
            saveContext()
            setToggleActivityIndicator(isOn: false)
            dismiss(animated: true, completion: nil)
        } else {
            setToggleActivityIndicator(isOn: false)
            hapticControl(result: .failure)
        }
    }
    
    func photoLibrayDidSelect() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.images
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        setToggleActivityIndicator(isOn: true)
        guard !results.isEmpty else {
            setToggleActivityIndicator(isOn: false)
            return
        }
        for i in results {
            i.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {[weak self](image, error) in
                guard let self = self, let dishVM = self.dishListVM?.currentDish else {return}
                if let image = image as? UIImage {
                    dishVM.deleteFile()
                    if let newImage = image.fixImageOrientation() {
                        dishVM.setImage(image: newImage)
                        dishVM.createDirectory()
                        dishVM.retrieveFile()
                        DispatchQueue.main.async {
                            self.setToggleActivityIndicator(isOn: false)
                            self.dishImageView.image = dishVM.thumbNailImage
                            self.dishImageView.layer.borderWidth = 0.5
                        }
                        self.saveContext()
                    } else {
                        Util.hapticError()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.setToggleActivityIndicator(isOn: false, hapticHandler: {[weak self] in
                            guard let self = self else{return}
                            self.simpleErrorAlert(item: .image)
                            self.hapticControl(result: .failure)
                        })
                    }
                }
            } )
        }
    }
}

//MARK: CORE DATA METHODS
extension DishController {
    func retrieveCoreDishes() { //fetching all dishes by creation date [(earliest)...(Most recent)]
        guard let context = context else {return}
        let fetchRequest: NSFetchRequest<CoreDish> = CoreDish.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true) //last dish is latest dated dish
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dishes = try context.fetch(fetchRequest)
        }
        catch{
            print("unable to fetch core data")
            return
        }
    }
    
    func saveContext() {
        guard let context = context else {return}
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: OTHER VC DELEGATE METHODS
extension DishController: AddIngredientControllerDelegate {
    func didAddIngredient(ingredientVM: IngredientViewModel) {
        guard let dishVM = dishListVM?.currentDish else {return}
        dishVM.setStepperValue(stepperValue: ingredientVM.stepperServingsValue)
        //if updating shouldn't add Ingredient
        if ingredientVM.updateState == .new {
            dishVM.addIngredient(ingredientVM: ingredientVM)
        }
        dishVM.multiplyIngredients()
        saveContext()
        outletViewConfig()
        navigationConfig()
        tableView.reloadData()
    }
}

extension DishController: ImageDetailDelegate {
    func didDeleteImage(result: Bool) {
        guard let currentDish = dishListVM?.currentDish, result == true else {return}
        currentDish.deleteFile()
        currentDish.removeImage()
        self.saveContext()
        self.dishImageView.image = currentDish.thumbNailImage
    }
}

