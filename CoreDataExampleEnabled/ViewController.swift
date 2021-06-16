//
//  ViewController.swift
//  CoreDataExampleEnabled
//
//  Created by Marius Preikschat on 16.06.21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchPeople()
    }
    
    // MARK: setting relationships example
    
    func relationshipDemo() {
        let family = Family(context: context)
        family.name = "Preikschat"
        
        let person = Person(context: context)
        person.name = "Bjarki"
        person.age = 5
        person.gender = "male"
        
        // 1. way
        family.addToMembers(person)
        // 2. way
//        person.family = family
        
        try! context.save()
    }
    
    // MARK: fetchPeople
    
    func fetchPeople() {
        do {
            
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            // filtering
//            let predicate = NSPredicate(format: "name CONTAINS %@", "Marius")
//            request.predicate = predicate
            
            // sorting
//            let sortDesc = NSSortDescriptor(key: "name", ascending: true)
//            request.sortDescriptors = [sortDesc]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }
    }
    
    // MARK: addButton
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let textField = alert.textFields![0]
            
            let newPerson = Person(context: self.context)
            newPerson.name = textField.text
            newPerson.age = 27
            newPerson.gender = "male"
            
            try!self.context.save()
            
            self.fetchPeople()
        }
        
        alert.addAction(submitButton)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Extension for TableView

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell") else {
            return UITableViewCell()
        }
        
        let person = self.items![indexPath.row]
        
        cell.textLabel?.text = person.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.items![indexPath.row]
        
        let alert = UIAlertController(title: "Edit person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields![0]
        textField.text = person.name
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            let textField = alert.textFields![0]
            
            person.name = textField.text
            
            try! self.context.save()
            
            self.fetchPeople()
        }
        
        alert.addAction(saveButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            
            let personToRemove = self.items![indexPath.row]
            self.context.delete(personToRemove)
            
            try! self.context.save()
            self.fetchPeople()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}
