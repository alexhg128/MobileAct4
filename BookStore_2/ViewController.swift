//
//  ViewController.swift
//  BookStore_2
//
//  Created by Alejandro Hahn Gallegos on 29/03/20.
//  Copyright © 2020 Alejandro Hahn Gallegos. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadBooks().count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            else {
                return UITableViewCell()
        }
        
        let book: Book = loadBooks()[indexPath.row]
        cell.textLabel?.text = book.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let book : Book = loadBooks()[indexPath.row]
                managedObjectContext.delete(book)
                try managedObjectContext.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                NSLog("My Error: %@", error)
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    @IBOutlet weak var myTableView : UITableView!
    @IBOutlet weak var editButton : UIBarButtonItem!
    @IBOutlet weak var toolbar : UINavigationItem!
    var managedObjectContext : NSManagedObjectContext!
    var ascending : Bool = true
    var tvediting : Bool = false
    var prefs: UserDefaults = UserDefaults.standard
    var counter : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext as NSManagedObjectContext
        myTableView.allowsMultipleSelectionDuringEditing = true
        counter = prefs.integer(forKey: "counter")
        rightButtons = toolbar.rightBarButtonItems!
    }
    
    @IBAction func addNew(_ sender: UIBarButtonItem) {
        let book: Book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: managedObjectContext) as! Book
        counter += 1
        book.title = "My Book " + String(counter)
        prefs.synchronize()
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("My Error: %@", error)
        }
        
        myTableView.reloadData()
    }
    
    var rightButtons : [UIBarButtonItem] = []
    
    
    @IBAction func toogleEditing(_ sender: UIBarButtonItem?) {
        tvediting = !tvediting;
        myTableView.setEditing(tvediting, animated: true)
        let button = UIBarButtonItem(barButtonSystemItem: tvediting ? UIBarButtonItem.SystemItem.done : UIBarButtonItem.SystemItem.edit, target: self, action: #selector(toogleEditing(_:)))
        if tvediting {
            let trash : [UIBarButtonItem] = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deleteSelected(_:)))]
            toolbar.setRightBarButtonItems(trash, animated: true)
            toolbar.setLeftBarButton(button, animated: true)
        } else {
            toolbar.setRightBarButtonItems(rightButtons, animated: true)
            toolbar.setLeftBarButton(nil, animated: true)
        }
    }
    
    @IBAction func deleteSelected(_ sender: UIBarButtonItem) {
        
        if let selectedRows = myTableView.indexPathsForSelectedRows {
            let books : [Book] = loadBooks()
            for indexPath in selectedRows  {
                managedObjectContext.delete(books[indexPath.row])
            }
            do {
                try managedObjectContext.save()
                myTableView.beginUpdates()
                myTableView.deleteRows(at: selectedRows, with: .automatic)
                myTableView.endUpdates()
                toogleEditing(nil)
            } catch let error as NSError {
                NSLog("My Error: %@", error)
            }
        }
    }
    
    @IBAction func changeOrder(_ sender: UIBarButtonItem) {
        ascending = !ascending
        myTableView.reloadData()
    }
    
    func loadBooks() -> [Book] {
        let fetchRequest : NSFetchRequest<Book> = Book.fetchRequest()
        let sort = NSSortDescriptor(key: "title", ascending: ascending)
        fetchRequest.sortDescriptors = [sort]
        var result : [Book] = []
        
        do {
            result = try managedObjectContext.fetch(fetchRequest)
        } catch {
            NSLog("My Error: %@", error as NSError)
        }
        
        return result
    }

}

