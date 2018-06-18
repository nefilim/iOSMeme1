//
//  ViewController.swift
//  PickImage
//
//  Created by peter on 6/3/18.
//  Copyright © 2018 peter. All rights reserved.
//

import UIKit

class ImagePickerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -1.0]
    
    private func setupTextField(_ field: UITextField) {
        field.defaultTextAttributes = memeTextAttributes
        field.textAlignment = .center
        field.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        field.borderStyle = .none
        field.autocapitalizationType = .allCharacters
        field.delegate = memeTextFieldDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.text = "TOP"
        setupTextField(topTextField)

        bottomTextField.text = "BOTTOM"
        setupTextField(bottomTextField)
        
        setButtonStates()
    }
    
    private func setButtonStates() {
        shareButton.isEnabled = imagePickerView.image != nil
        cancelButton.isEnabled = imagePickerView.image != nil
    }
    
    private func hideNavAndToolbars(_ hide: Bool) {
        toolbar.isHidden = hide
        navigationBar.isHidden = hide
    }
    
    func compositeMemedImage() -> UIImage {
        hideNavAndToolbars(true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let compositedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideNavAndToolbars(false)

        return compositedImage
    }
    
    func save() -> Meme {
        return Meme(
            topText: topTextField.text,
            bottomText: bottomTextField.text,
            originalImage: imagePickerView.image!,
            compositedImage: compositeMemedImage()
        )
    }
    
    private func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if (bottomTextField.isFirstResponder) {
            view.frame.origin.y = 0
        }
    }

    func subscribeToKeyboardNotifications() {
        print("subscribing to keyboard notifications")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        print("UNsubscribing to keyboard notifications")
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled image picker!")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("picked an image \(info["UIImagePickerControllerOriginalImage"])")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePickerView.image = image
        }
        setButtonStates()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        presentImagePickerController(UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        presentImagePickerController(UIImagePickerControllerSourceType.photoLibrary)
    }
    
    private func presentImagePickerController(_ source: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    private func completeHandler(activity: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) -> Void {
        print("calling to complete handler!! activity \(activity) completed: \(completed) returnedItems \(returnedItems)")
        if (completed) {
            save()
        }
    }
    
    @IBAction func share(_ sender: Any) {
        let meme = save()
        let activityViewController = UIActivityViewController(activityItems: [meme.compositedImage!], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = completeHandler
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        imagePickerView.image = nil;
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        setButtonStates()
    }
}

