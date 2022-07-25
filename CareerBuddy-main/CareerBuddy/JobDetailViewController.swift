//
//  JobDetailViewController.swift
//  CareerBuddy
//
//  Created by Ilija Milisav on 2022-04-05.
//

import UIKit
import CoreData

class JobDetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var jobIDLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var posting: NSManagedObject?
    let context = AppDelegate.viewContext
    let editJobSegue = "EditJobSegue"
    
    func initWithPosting(posting: NSManagedObject) {
        self.posting = posting
    }
    
    func getPosting() -> NSManagedObject? {
        return posting
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if statusLabel.text == "Archived"{
            archiveButton.isHidden = true
            activeButton.isHidden = false
            editButton.isHidden = true
        }else{
            archiveButton.isHidden = false
            activeButton.isHidden = true
            editButton.isHidden = false
        }
        
        self.view.backgroundColor = UIColor(hex: (posting?.value(forKey: "color") as? String)!)
        
        companyLabel.text = posting?.value(forKey: "company") as? String
        titleLabel.text = posting?.value(forKey: "title") as? String
        jobIDLabel.text = posting?.value(forKey: "jobId") as? String
        statusLabel.text = posting?.value(forKey: "status") as? String
        descTextView.text = posting?.value(forKey: "desc") as? String
        
        descTextView.delegate = self
        descTextView.isEditable = false
        descTextView.layer.borderColor = UIColor.gray.cgColor
        descTextView.layer.borderWidth = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if statusLabel.text == "Archived"{
            archiveButton.isHidden = true
            activeButton.isHidden = false
            editButton.isHidden = true
        }else{
            archiveButton.isHidden = false
            activeButton.isHidden = true
            editButton.isHidden = false
        }
    }
        
    @IBAction func editBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: editJobSegue, sender: posting)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == editJobSegue {
            let editJobViewController = segue.destination as! EditJobViewController;
            editJobViewController.initWithPosting(posting: sender as! NSManagedObject)
        }
        
        let button = sender as? UIButton
        if button === archiveButton {
            posting?.setValue("Archived" , forKey: "status")
            let archivedColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            posting?.setValue(archivedColor.htmlRGBaColor, forKey: "color")
            do {
                try context.save()
                let alert = UIAlertController(title: "Posting Archived",
                                              message: "\(posting?.value(forKey: "title")! ?? "Posting") was archived!",
                                              preferredStyle: .alert)
                
                present(alert, animated: true, completion: nil)
            } catch let error as NSError {
                print("Could not archive posting. \(error), \(error.userInfo)")
            }
        } else if button === activeButton {
            posting?.setValue("Active" , forKey: "status")
            let activeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            posting?.setValue(activeColor.htmlRGBaColor, forKey: "color")
            do {
                try context.save()
                let alert = UIAlertController(title: "Posting Active",
                                              message: "\(posting?.value(forKey: "title")! ?? "Posting") is active again!",
                                              preferredStyle: .alert)
                
                present(alert, animated: true, completion: nil)
            } catch let error as NSError {
                print("Could not making posting active. \(error), \(error.userInfo)")
            }
        }
    }
}
