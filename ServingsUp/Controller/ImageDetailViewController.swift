//
//  ImageDetailViewController.swift
//  ServingsUp
//
//  Created by Elias Hall on 4/21/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var currentDishImage: UIImage?
    var delegate: ImageDetailDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        if let currentDishImage = currentDishImage {
            tabBarController?.tabBar.isHidden = true
            imageView.image = currentDishImage
            imageView.isUserInteractionEnabled = true
            setGestureRecognizers()
            view.backgroundColor = .black
            scrollView.delegate = self
            setToggleActivityIndicator(isOn: false)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false //prevents slide to prev VC
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func optionsButtonDidTouch(_ sender: UIBarButtonItem) {
        optionsActionSheet()
    }
    
    func setGestureRecognizers() {
        let doubleTapGesuture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScrollView))
        doubleTapGesuture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesuture)
    }
    
    func saveImage() {
        guard let currentDishImage = currentDishImage else {return}
        setToggleActivityIndicator(isOn: true)
        UIImageWriteToSavedPhotosAlbum(currentDishImage, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        setToggleActivityIndicator(isOn: false)
        guard error == nil else {
            failSaveError()
            return
        }
        successSaveAlert()
        Util.hapticSuccess()
    }
    
    func setToggleActivityIndicator(isOn: Bool) {
        activityIndicator.isHidden = !isOn
        activityIndicator.isHidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
}

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc func didDoubleTapScrollView() {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            scrollView.setZoomScale(1.5, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1  { //if zoomed in
            if let image = imageView.image {
                let widthProp = imageView.frame.width / image.size.width //how big image is relative to imageView
                let heightProp = imageView.frame.height / image.size.height
                
                let ratio = widthProp < heightProp ? widthProp:heightProp
                let updatedWidth = image.size.width * ratio
                let updatedHeight = image.size.height * ratio
                
                let left = 0.5 * (updatedWidth * scrollView.zoomScale > imageView.frame.width ? (updatedWidth - imageView.frame.width):(scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (updatedHeight * scrollView.zoomScale > imageView.frame.height ? (updatedHeight - imageView.frame.height):(scrollView.frame.height - scrollView.contentSize.height))
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
}

extension ImageDetailViewController {
    //Alerts
    func optionsActionSheet() {
        let actionSheet = UIAlertController(title: "Save/Delete Image", message: "You can delete this image or save it to your photo library", preferredStyle: .actionSheet)
        actionSheetiPadUpdate(actionSheet: actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Image", style: .destructive, handler: {[weak self]_ in
            guard let self = self else {return}
            self.deleteAlert()
        })
        
        let saveAction = UIAlertAction(title: "Save Image", style: .default, handler: {[weak self]_ in
            guard let self = self else {return}
            self.saveImage()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    func successSaveAlert() {
        let alert = UIAlertController(title: "Saved", message: "Your image has been saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
        })
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func failSaveError() {
        let alert = UIAlertController(title: "Error", message: "There was an error saving your image", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
    func deleteAlert() {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self]_ in
            guard let self = self else {return}
            guard let delegate = self.delegate else {return}
            
            delegate.didDeleteImage(result: true)
            Util.hapticSuccess()
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert,animated: true)
    }
}
