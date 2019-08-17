//
//  ChangeLabelTableViewController.swift
//  Todo
//
//  Created by IcyBlast on 7/6/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

protocol backChangedLabelProtocol_ChangeLabel_Main
{
    func backChangedLabelFunc_ChangeLabel_Main(changedLabel: String)
}

class ChangeLabelTableViewController: UITableViewController
{
    var userName: String = ""
    var labelName: String = ""
    var eventName: String = ""
    var newLabel: String = ""
    
    var eventList: [UserEvents] = []
    var labelList: [UserLabels] = []
    
    var backDelegate: backChangedLabelProtocol_ChangeLabel_Main?

    @IBAction func changeLabelTableViewControllerNavigationRightButton(_ sender: Any)
    {
        var originalEvent: UserEvents? = nil
        var originalDate: NSDate? = nil
        var originalPlace: String = ""
        var originalNote: String = ""
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        
        //get the original event
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        fetchRequest.predicate = NSPredicate(format: "eventsName = '\(eventName)'")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserEvents]
            for info in fetchedObjects
            {
                if info.labels?.labelName == self.labelName && info.labels?.users?.userName == self.userName
                {
                    originalEvent = info
                    originalDate = info.eventsDate
                    originalPlace = info.eventsPlace!
                    originalNote = info.eventsNote!
                }
            }
            print("\n")
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        
        // delete from the original label
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserLabels]
            for info in fetchedObjects
            {
                if info.labelName == self.labelName && info.users?.userName == self.userName
                {
                    info.removeFromEvents(originalEvent!)
                    context.delete(originalEvent!)
                    try context.save()
                }
            }
            print("\n")
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        
        // add to the new label
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserLabels]
            for info in fetchedObjects
            {
                if info.labelName == newLabel && info.users?.userName == self.userName
                {
                    let newEvent = NSEntityDescription.insertNewObject(forEntityName: "UserEvents", into: context) as! UserEvents
                    newEvent.eventsName = eventName
                    newEvent.eventsDate = originalDate
                    newEvent.eventsPlace = originalPlace
                    newEvent.eventsNote = originalNote
                    
                    info.addToEvents(newEvent)
                    self.backDelegate?.backChangedLabelFunc_ChangeLabel_Main(changedLabel: labelName)
                    try context.save()
                }
            }
            print("\n")
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(userName)'")
        do
        {
            let user = try context.fetch(fetchRequest) as! [UserInformation]
            print(user.count)
            labelList = user.first?.labels?.allObjects as! [UserLabels]
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return labelList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "changeLabelCell", for: indexPath)
        cell.textLabel?.text = labelList[indexPath.row].labelName
        
        if labelList[indexPath.row].labelName == newLabel
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        newLabel = labelList[indexPath.row].labelName!
        print(newLabel)
        self.tableView?.reloadData()
    }

}
