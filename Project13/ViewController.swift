//
//  ViewController.swift
//  Project13
//
//  Created by Keith Crooc on 2021-09-19.



// challenge:
//  1. Make save button show error if there is no image in the imageview ✅
//  2. Make change filter button change it's title to show name of the currently selected filter ✅
//  3. Experiment with having more than one slider. (eg: 1 for radius, other for intensity)

import CoreImage
import UIKit

class ViewController: UIViewController,
//                      these two are required in order to be a image picker controller
                      UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var Intensity: UISlider!
    @IBOutlet var ImageView: UIImageView!
//    added an IBOutlet for the change filter button so I can reference it in handler to change it's name to the filter selected
    @IBOutlet var changeFilterButton: UIButton!
    
    var currentImage: UIImage!
    
    var context: CIContext!
//    context = handles rendering.
    var currentFilter: CIFilter!
//    we'll use this to store whatever filter is activated
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    
        applyProcessing()
    }
    
    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        
        
        present(ac, animated: true)
    }
    
    
    func setFilter(action: UIAlertAction) {
        
        changeFilterButton.setTitle(action.title, for: .normal)
//        this is so when the button is clicked and filter is selected - the button name changes to the action.title
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        
        
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
//        we write this so that our app doesn't crash. Initially we had it in the UIImageWriteToSavedPhotosAlbum as "ImageView.image!" (force unwrapped)
        guard let image = ImageView.image else {
            let ac = UIAlertController(title: "No Image Selected", message: "There is no image to save", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
            
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfor:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing() {
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(Intensity.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(Intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(Intensity.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        
        
//        currentFilter.setValue(Intensity.value, forKey: kCIInputIntensityKey)
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            ImageView.image = processedImage
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfor: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos", preferredStyle: .alert)
            present(ac, animated: true)
        }
    }
    
}

