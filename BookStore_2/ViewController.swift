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
    
    
    @IBOutlet weak var myTableView : UITableView!
    var managedObjectContext : NSManagedObjectContext!
    var ascending : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext as NSManagedObjectContext
    }
    
    @IBAction func addNew(_ sender: UIBarButtonItem) {
        let book: Book = NSEntityDescription.insertNewObject(forEntityName: "Book", into: managedObjectContext) as! Book
        book.title = "My Book " + String(loadBooks().count)
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("My Error: %@", error)
        }
        
        myTableView.reloadData()
    }
    
    @IBAction func deleteOne(_ sender: UIBarButtonItem) {
        
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        let pred = NSPredicate(format: "(title = %@)", "My Book " + String(loadBooks().count))
        request.predicate = pred
        
        do {
            let books : [Book] = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Book]
            managedObjectContext.delete(books[0])
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog("My Error: %@", error)
        }
        
        myTableView.reloadData()
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

