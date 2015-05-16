//
//  StarListTableViewController.swift
//  Stargazer
//
//  Created by Dongyuan Liu on 2015-05-05.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import CoreData
import TagListView

class StarListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var stars: [[String: AnyObject]] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Repo")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        fetchStars()
        
        var error: NSError? = nil
        if fetchedResultsController.performFetch(&error) == false {
            print("An error occurred: \(error?.localizedDescription)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fetchStars() {
        Client.sharedInstance.getStarred() { stars in
            self.stars.extend(stars)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! StarListTableViewCell
        
        let repo = fetchedResultsController.objectAtIndexPath(indexPath) as! Repo
        cell.nameLabel.text = repo.name
        cell.languageLabel.text = repo.language
        cell.languageLabel.textColor = UIColor(red: 0.88, green: 0.31, blue: 0.22, alpha: 1)
        cell.starsLabel.text = toString(repo.stargazers_count as? Int ?? 0)
        cell.descriptionLabel.text = repo.desc
        
        cell.tagListView.removeAllTags()
        for tag in ["test", "tag", "animation", "something"] {
            cell.tagListView.addTag(tag)
        }
        
        cell.updateConstraintsIfNeeded()

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow()!
        let starItem = stars[indexPath.row]
        
        let webViewController = segue.destinationViewController as! StarWebViewController
        webViewController.title = starItem["name"] as? String
        webViewController.URLString = starItem["html_url"] as? String
    }

}
