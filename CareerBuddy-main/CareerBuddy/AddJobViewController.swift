//
//  AddJobViewController.swift
//  CareerBuddy
//
//  Created by Ilija Milisav on 2022-04-05.
//

import UIKit
import CoreData

class AddJobViewController: UIViewController, UITextViewDelegate, UIColorPickerViewControllerDelegate {
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var jobIDTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var colorView: UIView!
    
    let context = AppDelegate.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descTextView.delegate = self
        descTextView.layer.borderColor = UIColor.gray.cgColor
        descTextView.layer.borderWidth = 1.0
        
        colorView.layer.borderColor = UIColor.gray.cgColor
        colorView.layer.borderWidth = 1.0
        
        // Do any additional setup after loading the view.
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
    
    // MARK: - Keyboard gestures
    
    // Tap anywhere to dismiss the keyboard
    @IBAction func dismissKeyboardTap(_ sender: Any) {
        companyTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        jobIDTextField.resignFirstResponder()
        statusTextField.resignFirstResponder()
        descTextView.resignFirstResponder()
    }
    
    // MARK: - Save Button
    @IBAction func savePersonBtnPressed(_ sender: Any) {
        let companyName = companyTextField.text
        let jobID = jobIDTextField.text
        let title = titleTextField.text
        let desc = descTextView.text
        let status = statusTextField.text
        let color = UIColor(cgColor: colorView.backgroundColor!.cgColor)
        
        let entity = NSEntityDescription.entity(forEntityName: "JobPosting", in: context)!
        let posting = NSManagedObject(entity: entity, insertInto: context)
        
        posting.setValue(UUID(), forKeyPath: "id")
        posting.setValue(companyName, forKey: "company")
        posting.setValue(jobID, forKey: "jobId")
        posting.setValue(title, forKey: "title")
        posting.setValue(desc, forKey: "desc")
        posting.setValue(status, forKey: "status")
        posting.setValue(color.htmlRGBaColor, forKey: "color")

        do {
            try context.save()
            let alert = UIAlertController(title: "Posting Added",
                                          message: "\(title!) was added!",
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save posting. \(error), \(error.userInfo)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0,0,0,0)
    }
    // hue, saturation, brightness and alpha components from UIColor**
    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
            return (hue,saturation,brightness,alpha)
        }
        return (0,0,0,0)
    }
    var htmlRGBaColor:String {
        return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
    }
}
