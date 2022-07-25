//
//  EditJobViewController.swift
//  CareerBuddy
//
//  Created by Ilija Milisav on 2022-04-05.
//

import UIKit
import CoreData

class EditJobViewController: UIViewController, UITextViewDelegate, UIColorPickerViewControllerDelegate {
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var jobIDTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var colorView: UIView!
    
    var posting: NSManagedObject?
    
    let context = AppDelegate.viewContext
    
    func initWithPosting(posting: NSManagedObject) {
        self.posting = posting
    }
    
    public func getPosting() -> NSManagedObject? {
        return posting
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate the UI
        companyTextField.text = posting?.value(forKey: "company") as? String
        titleTextField.text = posting?.value(forKey: "title") as? String
        jobIDTextField.text = posting?.value(forKey: "jobId") as? String
        statusTextField.text = posting?.value(forKey: "status") as? String
        descTextView.text = posting?.value(forKey: "desc") as? String
        
        descTextView.delegate = self
        descTextView.layer.borderColor = UIColor.gray.cgColor
        descTextView.layer.borderWidth = 1.0
        
        colorView.layer.borderColor = UIColor.gray.cgColor
        colorView.layer.borderWidth = 1.0
    }
    
    // MARK: - Keyboard gestures
    
    // Tap anywhere to dismiss the keyboard
    @IBAction func dismissKeyboardTap(_ sender: Any) {
        companyTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        jobIDTextField.resignFirstResponder()
        statusTextField.resignFirstResponder()
        descTextView.resignFirstResponder()
    }
    
    // MARK: - Color Functions
    @IBAction func colorBtnPressed(_ sender: Any) {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        self.colorView.backgroundColor = viewController.selectedColor
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === saveBtn else {
            print("The save button was not pressed, cancelling")
            return
        }
        
        let companyName = companyTextField.text
        let jobID = jobIDTextField.text
        let title = titleTextField.text
        let desc = descTextView.text
        let status = statusTextField.text
        let color = UIColor(cgColor: colorView.backgroundColor!.cgColor)
        
        posting!.setValue(companyName, forKey: "company")
        posting!.setValue(jobID, forKey: "jobId")
        posting!.setValue(title, forKey: "title")
        posting!.setValue(desc, forKey: "desc")
        posting!.setValue(status, forKey: "status")
        posting!.setValue(color.htmlRGBaColor, forKey: "color")

        do {
            try context.save()
            let alert = UIAlertController(title: "Update Successful",
                                          message: "\(posting?.value(forKey: "title")! ?? "Posting") was updated!",
                                          preferredStyle: .alert)

            present(alert, animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save posting. \(error), \(error.userInfo)")
        }
    }

}
