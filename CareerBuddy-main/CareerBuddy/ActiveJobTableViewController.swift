//
//  TableViewController.swift
//  CareerBuddy
//
//  Created by Ilija Milisav on 2022-04-05.
//

import UIKit
import CoreData



class ActiveJobTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate  {
    
    let context = AppDelegate.viewContext
    
    var postings: [NSManagedObject] = []
    let tableIdentifier = "ActivePostingsTable"
    let jobDetailsSegue = "JobDetailsSegue"
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var activeTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate=self
        fetchPostings()
        activeTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPostings()
        activeTableView.reloadData()
    }

    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(
                style: UITableViewCell.CellStyle.subtitle,
                reuseIdentifier: tableIdentifier)
        }
        
        let posting = postings[indexPath.row]
        cell?.textLabel?.text = posting.value(forKey: "title") as? String
        cell?.detailTextLabel?.text = posting.value(forKey: "company") as? String
        let hexColor = posting.value(forKey: "color") as? String
        cell?.backgroundColor = UIColor(hex: hexColor!)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let posting = postings[indexPath.row]
        performSegue(withIdentifier: jobDetailsSegue, sender: posting)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let posting = postings[indexPath.row]
                    context.delete(posting)
                    

                    postings.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)

            saveContext()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "title contains[c] '\(searchText)'")
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"JobPosting")
            fetchRequest.predicate = predicate
            do {
                postings = try context.fetch(fetchRequest) as! [NSManagedObject]
            } catch let error as NSError {
                print("Could not fetch. \(error)")
            }
        }else{
            fetchPostings()
        }
        activeTableView.reloadData()
    }
    
    // MARK: - Keyboard gestures
    
    // Tap anywhere to dismiss the keyboard
    @IBAction func dismissKeyboardTap(_ sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        searchBar.resignFirstResponder()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == jobDetailsSegue {
            let jobDetailViewController = segue.destination as! JobDetailViewController;
            jobDetailViewController.initWithPosting(posting: sender as! NSManagedObject)
        }
    }
    
    @IBAction func unwindToActiveView(_ sender: UIStoryboardSegue) {
        if sender.source is EditJobViewController || sender.source is JobDetailViewController {
            fetchPostings()
            activeTableView.reloadData()
        }
    }
    
    // MARK: - Core Data Functions
    func fetchPostings() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JobPosting")
        fetchRequest.predicate = NSPredicate(format: "status != %@", argumentArray: ["Archived"])
        do {
            postings = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Context Functions
    func saveContext(){
        if context.hasChanges{
            do {
                try context.save()
            }catch{
                print("An error has occured while saving: \(error)")
            }
        }
    }

}

//extension UIColor {
//    public convenience init?(hex: String) {
//        let r, g, b, a: CGFloat
//
//        if hex.hasPrefix("#") {
//            let start = hex.index(hex.startIndex, offsetBy: 1)
//            let hexColor = String(hex[start...])
//
//            if hexColor.count == 8 {
//                let scanner = Scanner(string: hexColor)
//                var hexNumber: UInt64 = 0
//
//                if scanner.scanHexInt64(&hexNumber) {
//                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
//                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
//                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
//                    a = CGFloat(hexNumber & 0x000000ff) / 255
//
//                    self.init(red: r, green: g, blue: b, alpha: a)
//                    return
//                }
//            }
//        }
//
//        return nil
//    }
//
//    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        var r:CGFloat = 0
//        var g:CGFloat = 0
//        var b:CGFloat = 0
//        var a:CGFloat = 0
//        if getRed(&r, green: &g, blue: &b, alpha: &a) {
//            return (r,g,b,a)
//        }
//        return (0,0,0,0)
//    }
//    // hue, saturation, brightness and alpha components from UIColor**
//    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
//        var hue:CGFloat = 0
//        var saturation:CGFloat = 0
//        var brightness:CGFloat = 0
//        var alpha:CGFloat = 0
//        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
//            return (hue,saturation,brightness,alpha)
//        }
//        return (0,0,0,0)
//    }
//    var htmlRGBColor:String {
//        return String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255))
//    }
//    var htmlRGBaColor:String {
//        return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
//    }
//}
