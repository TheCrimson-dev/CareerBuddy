//
//  ArchivedJobTableViewController.swift
//  CareerBuddy
//
//  Created by Ilija Milisav on 2022-04-05.
//

//
//  TableViewController.swift
//  CareerBuddy
//
//  Created by Ilija Milisav on 2022-04-05.
//

import UIKit
import CoreData

class ArchiveJobTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate{
    
    let context = AppDelegate.viewContext
    
    var postings: [NSManagedObject] = []
    let tableIdentifier = "ArchivedPostingsTable"
    let jobDetailsSegue = "ArchivedJobDetailSegue"
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var archivedTableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate=self
        fetchPostings()
        archivedTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPostings()
        archivedTableView.reloadData()
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
        
        archivedTableView.reloadData()
    }
    
    // MARK: - Keyboard gestures
    
    // Tap anywhere to dismiss the keyboard
    @IBAction func dismissKeyboardTap(_ sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        searchBar.resignFirstResponder()
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
        cell?.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let posting = postings[indexPath.row]
        performSegue(withIdentifier: jobDetailsSegue, sender: posting)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let posting = postings[indexPath.row]
                    context.delete(posting)
                    postings.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)

            saveContext()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == jobDetailsSegue {
            let jobDetailViewController = segue.destination as! JobDetailViewController;
            jobDetailViewController.initWithPosting(posting: sender as! NSManagedObject)
        }
    }
    
    @IBAction func unwindToArchiveView(_ sender: UIStoryboardSegue) {
        if sender.source is JobDetailViewController {
            fetchPostings()
            archivedTableView.reloadData()
        }
    }
    
    // MARK: - Core Data Functions
    func fetchPostings() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "JobPosting")
        fetchRequest.predicate = NSPredicate(format: "status == %@", argumentArray: ["Archived"])
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
