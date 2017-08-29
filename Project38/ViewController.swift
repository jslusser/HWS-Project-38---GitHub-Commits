//
//  ViewController.swift
//  Project38
//
//  Created by James Slusser on 8/28/17.
//  Copyright © 2017 James Slusser. All rights reserved.
//  https://www.hackingwithswift.com/read/38/overview
//

import CoreData
import UIKit

class ViewController: UITableViewController {
    
    var container: NSPersistentContainer!
    var commits = [Commit]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "Project38")
        
        container.loadPersistentStores { storeDescription, error in
            //self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        //let commit = Commit()
        //commit.message = "Woo"
        //commit.url = "http://www.example.com"
        //commit.date = Date()

        performSelector(inBackground: #selector(fetchCommits), with: nil)
        
        loadSavedData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }

    func fetchCommits() {
        //let newestCommitDate = getNewestCommitDate()
        
        if let data = try? Data(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!) {
            //&since=\(newestCommitDate)")!) {
            let jsonCommits = JSON(data: data)
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    //more code to go here!
                    // the following three lines are new
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                
                self.saveContext()
                self.loadSavedData()
            }
        }
    }
    
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        //return fetchedResultsController.sections?.count ?? 0
    }
    
    //override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //    return fetchedResultsController.sections![section].name
    //}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return commits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        //let commit = fetchedResultsController.object(at: indexPath)
        let commit = commits[indexPath.row]
        cell.textLabel!.text = commit.message
        //cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"
        cell.detailTextLabel!.text = commit.date.description
        
        return cell
    }
    
    func loadSavedData() {
        //if fetchedResultsController == nil {
        let request = Commit.createFetchRequest()
        //let sort = NSSortDescriptor(key: "author.name", ascending: true)
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        //request.fetchBatchSize = 20
        
        //fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
        //fetchedResultsController.delegate = self
    //}
    
    //fetchedResultsController.fetchRequest.predicate = commitPredicate
    
    do {
    commits = try container.viewContext.fetch(request)
    //try fetchedResultsController.performFetch()
    
    print("Got \(commits.count) commits")
    tableView.reloadData()
    } catch {
    print("Fetch failed")
    }
}

}
