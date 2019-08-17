//
//  DetailsTableViewController.swift
//  Todo
//
//  Created by IcyBlast on 30/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

class DetailsTableViewController: UITableViewController, UITextViewDelegate, backCoordinateProtocol_Location_Details
{
    func coordinateFunc_Location_Details(longitude: CLLocationDegrees, latitude: CLLocationDegrees)
    {
        print(longitude, latitude)
        self.longitude = longitude
        self.latitude = latitude
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
        do
        {
            let eventList = try context.fetch(fetchRequest) as! [UserEvents]
            for event in eventList
            {
                if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                {
                    
                    event.eventsPlace = "\(self.latitude)_\(self.longitude)"
                    
                    var requestIdentifier = "\(event.eventsName!)_\(event.eventsPlace!)"
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
                    
                    let content = UNMutableNotificationContent()
                    content.title = self.eventName
                    content.body = self.eventNote
                    
                    let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                    let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "center")
                    region.notifyOnEntry = true
                    region.notifyOnExit = false
                    let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                    
                    requestIdentifier = "\(event.eventsName!)_\(self.latitude)_\(self.longitude)"
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                    {
                        error in
                        if error == nil
                        {
                            print("Time Interval Notification scheduled: \(requestIdentifier)")
                        }
                    }
                }
            }
            try context.save()
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }
    
    var alarmIsOpen: Bool = false
    var timePickerIsOpen: Bool = false
    var locationPickerIsOpen: Bool = false
    var alarmTime: String = ""
    var alarmPlace: String = ""
    
    var timer:Timer!
    
    var longitude: CLLocationDegrees = 0.0
    var latitude: CLLocationDegrees = 0.0
    
    var userName: String = ""
    var labelName: String = ""
    var eventName: String = ""
    var eventNote: String = ""
    
    var year: Int = -1
    var month: Int = -1
    var day: Int = -1
    var hour: Int = -1
    var minute: Int = -1

    @IBOutlet weak var DetailsTableViewControllerNoteUITextView: UITextView!
    
    @IBOutlet weak var detailsTableViewControllerTimeSwitch: UISwitch!
    @IBAction func detailsTableViewControllerRemindTimeSwitch(_ sender: UISwitch)
    {
        if sender.isOn
        {
            alarmIsOpen = true
            tableView.beginUpdates()
            let indexPathAlarm = IndexPath(row: 1, section: 1)
            self.tableView.insertRows(at: [indexPathAlarm], with: .automatic)
            tableView.endUpdates()
        }
        else
        {
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext as NSManagedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
            fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
            do
            {
                let eventList = try context.fetch(fetchRequest) as! [UserEvents]
                for event in eventList
                {
                    if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                    {
                        let timeInterval:TimeInterval = TimeInterval(0)
                        event.eventsDate! = NSDate(timeIntervalSince1970: timeInterval)
                    }
                }
                try context.save()
            }
            catch
            {
                fatalError("Error：\(error)")
            }
            
            if !timePickerIsOpen
            {
                alarmIsOpen = false
                tableView.beginUpdates()
                let indexPathAlarm = IndexPath(row: 1, section: 1)
                self.tableView.deleteRows(at: [indexPathAlarm], with: .fade)
                tableView.endUpdates()
            }
            else
            {
                timePickerIsOpen = false
                alarmIsOpen = false
                tableView.beginUpdates()
                let indexPathTime = IndexPath(row: 2, section: 1)
                self.tableView.deleteRows(at: [indexPathTime], with: .fade)
                let indexpathAlarm = IndexPath(row: 1, section: 1)
                self.tableView.deleteRows(at: [indexpathAlarm], with: .fade)
                tableView.endUpdates()
            }
        }
    }
    
    @IBOutlet weak var detailsTableViewControllerLocationSwitch: UISwitch!
    @IBAction func detailsTableViewControllerRemindLocationSwitch(_ sender: UISwitch)
    {
        if sender.isOn
        {
            locationPickerIsOpen = true
            tableView.beginUpdates()
            let indexPathLocation = IndexPath(row: 1, section: 2)
            self.tableView.insertRows(at: [indexPathLocation], with: .automatic)
            tableView.endUpdates()
        }
        else
        {
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext as NSManagedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
            fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
            do
            {
                let eventList = try context.fetch(fetchRequest) as! [UserEvents]
                for event in eventList
                {
                    if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                    {
                        event.eventsPlace! = ""
                    }
                }
                try context.save()
            }
            catch
            {
                fatalError("Error：\(error)")
            }
            
            locationPickerIsOpen = false
            tableView.beginUpdates()
            let indexPathLocation = IndexPath(row: 1, section: 2)
            self.tableView.deleteRows(at: [indexPathLocation], with: .fade)
            tableView.endUpdates()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    {
        if indexPath.section == 1 && indexPath.row == 1
        {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        else if indexPath.section == 1 && indexPath.row == 2
        {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        else if indexPath.section == 2 && indexPath.row == 1
        {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        else
        {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print(userName)
        print(labelName)
        print(eventName)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(UIKeyboardWillHiden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleTap(sender:))))
        
        DetailsTableViewControllerNoteUITextView.delegate = self

        ini()
    }
    
    func ini()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
        do
        {
            let eventList = try context.fetch(fetchRequest) as! [UserEvents]
            for event in eventList
            {
                if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                {
                    print(event.eventsName!, convertDate(date: event.eventsDate!), event.eventsNote!, event.eventsPlace!)
                    self.eventNote = event.eventsNote!
                    
                    
                    alarmTime = convertDate(date: event.eventsDate!)
                    if alarmTime != "01/01/1970 10:00"
                    {
                        self.detailsTableViewControllerTimeSwitch.isOn = true
                        alarmIsOpen = true
                        tableView.beginUpdates()
                        let indexPathAlarm = IndexPath(row: 1, section: 1)
                        self.tableView.insertRows(at: [indexPathAlarm], with: .automatic)
                        tableView.endUpdates()
                    }
                    else
                    {
                        self.detailsTableViewControllerTimeSwitch.isOn = false
                        alarmIsOpen = false
                    }
                    
                    
                    alarmPlace = event.eventsPlace!
                    if alarmPlace != ""
                    {
                        self.detailsTableViewControllerLocationSwitch.isOn = true
                        locationPickerIsOpen = true
                        tableView.beginUpdates()
                        let indexPathAlarm = IndexPath(row: 1, section: 2)
                        self.tableView.insertRows(at: [indexPathAlarm], with: .automatic)
                        tableView.endUpdates()
                    }
                    else
                    {
                        self.detailsTableViewControllerLocationSwitch.isOn = false
                        locationPickerIsOpen = false
                    }
                }
            }
            try context.save()
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        DetailsTableViewControllerNoteUITextView.text = self.eventNote
    }
    
    func getTimes(date: NSDate) -> [Int]
    {
        var timers: [Int] = []
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
        
        timers.append(comps.year!)
        timers.append(comps.month!)
        timers.append(comps.day!)
        timers.append(comps.hour!)
        timers.append(comps.minute!)
        return timers
    }
    
    func convertDate(date:NSDate) -> String
    {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dformatter.string(from: date as Date)
    }
    
    @objc func UIKeyboardWillShow(notification: NSNotification)
    {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        UITextView.animate(withDuration: 0.1, animations: {
            print(self.tableView.frame.origin.y, height!)
            self.tableView.frame.origin.y -= height!
        })
    }
    
    @objc func UIKeyboardWillHiden(notification: NSNotification)
    {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        UITextView.animate(withDuration: 0.1, animations: {
            self.tableView.frame.origin.y += height!
        })
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        if sender.state == .ended {
            self.DetailsTableViewControllerNoteUITextView.resignFirstResponder()
            eventNote = self.DetailsTableViewControllerNoteUITextView.text
            saveEventNote()
        }
        sender.cancelsTouchesInView = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.DetailsTableViewControllerNoteUITextView.resignFirstResponder()
        eventNote = self.DetailsTableViewControllerNoteUITextView.text
        saveEventNote()
        return true
    }
    
    func saveEventNote()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
        do
        {
            let eventList = try context.fetch(fetchRequest) as! [UserEvents]
            for event in eventList
            {
                if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                {
                    event.eventsNote! = self.eventNote
                }
            }
            try context.save()
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
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 1 && alarmIsOpen && !timePickerIsOpen
        {
            return 2
        }
        else if section == 1 && alarmIsOpen && timePickerIsOpen
        {
            return 3
        }
        else if section == 2 && locationPickerIsOpen
        {
            return 2
        }
        else
        {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 1 && indexPath.row == 1
        {
            return 48
        }
        else if indexPath.section == 1 && indexPath.row == 2
        {
            return 216
        }
        else if indexPath.section == 2 && indexPath.row == 1
        {
            return 48
        }
        else
        {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 1 && indexPath.row == 1
        {
            if !timePickerIsOpen
            {
                timePickerIsOpen = true
                tableView.beginUpdates()
                let indexPathLocation = IndexPath(row: 2, section: 1)
                self.tableView.insertRows(at: [indexPathLocation], with: .automatic)
                tableView.endUpdates()
            }
            else
            {
                timePickerIsOpen = false
                tableView.beginUpdates()
                let indexPathLocation = IndexPath(row: 2, section: 1)
                self.tableView.deleteRows(at: [indexPathLocation], with: .fade)
                tableView.endUpdates()
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 1
        {
            let mainStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let locationVC = mainStoryboard.instantiateViewController(withIdentifier: "locationViewController") as! LocationViewController
            locationVC.locationDelegate = self
            self.navigationController?.pushViewController(locationVC, animated: true)
        }
        
        if indexPath.section == 3
        {
            self.DetailsTableViewControllerNoteUITextView.becomeFirstResponder()
        }
        
        if indexPath.section == 4
        {
            let alertController = UIAlertController(title: "This event will be deleted forever.", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let logoutAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
                
                let app = UIApplication.shared.delegate as! AppDelegate
                let context = app.persistentContainer.viewContext as NSManagedObjectContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
                fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
                do
                {
                    let eventList = try context.fetch(fetchRequest) as! [UserEvents]
                    for event in eventList
                    {
                        if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                        {
                            context.delete(event)
                        }
                    }
                    try context.save()
                }
                catch
                {
                    fatalError("Error：\(error)")
                }
                self.navigationController?.popToRootViewController(animated: true)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 1 && indexPath.row == 1
        {
            var alarmCell = tableView.dequeueReusableCell(withIdentifier: "alarmCell") as UITableViewCell?
            if alarmCell == nil
            {
                alarmCell = UITableViewCell(style: .value1, reuseIdentifier: "alarmCell")
                alarmCell?.textLabel?.text = "Alarm"
                alarmCell?.detailTextLabel?.text = alarmTime
                alarmCell?.tag = 1000
            }
            return alarmCell!
        }
        else if indexPath.section == 1 && indexPath.row == 2
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "timePickerCell") as UITableViewCell?
            if cell == nil
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "timePickerCell")
                cell?.selectionStyle = .none
                let datePicker = UIDatePicker(frame: CGRect(x:0, y:0, width:320, height:216))
                datePicker.tag = 100
                datePicker.locale = Locale(identifier: "en_AU")
                cell?.contentView.addSubview(datePicker)
                datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            }
            return cell!
        }
        else if indexPath.section == 2 && indexPath.row == 1
        {
            var locationCell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as UITableViewCell?
            if locationCell == nil
            {
                locationCell = UITableViewCell(style: .value1, reuseIdentifier: "locationCell")
                locationCell?.textLabel?.text = "Location"
                locationCell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                locationCell?.detailTextLabel?.text = "remind place"
            }
            return locationCell!
        }
        else
        {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    
    @objc func dateChanged(_ datePicker: UIDatePicker)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        alarmTime = formatter.string(from: datePicker.date)
        let cell = self.view.viewWithTag(1000) as! UITableViewCell
        cell.detailTextLabel?.text = alarmTime
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        fetchRequest.predicate = NSPredicate(format: "eventsName = '\(self.eventName)'")
        do
        {
            let eventList = try context.fetch(fetchRequest) as! [UserEvents]
            for event in eventList
            {
                if event.labels?.labelName == self.labelName && event.labels?.users?.userName == self.userName
                {
                    var requestIdentifier = "\(event.eventsName!)_\(getTimes(date: event.eventsDate!))"
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
                    
                    event.eventsDate = datePicker.date as NSDate
                    
                    let content = UNMutableNotificationContent()
                    content.title = self.eventName
                    content.body = self.eventNote
                    let date = getTimes(date: event.eventsDate! as NSDate)
                    var components = DateComponents()
                    components.year = date[0]
                    components.month = date[1]
                    components.day = date[2]
                    components.hour = date[3]
                    components.minute = date[4]
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    requestIdentifier = "\(event.eventsName!)_\(getTimes(date: event.eventsDate!))"
                    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                    {
                        error in
                        if error == nil
                        {
                            print("Time Interval Notification scheduled: \(requestIdentifier)")
                        }
                    }
                }
            }
            try context.save()
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "changeLabelSegue"
        {
            let changeLabelNC = segue.destination as! ChangeLabelNavigationController
            let changeLabelVC = changeLabelNC.topViewController as! ChangeLabelTableViewController
            changeLabelVC.userName = self.userName
            changeLabelVC.labelName = self.labelName
            changeLabelVC.eventName = self.eventName
            changeLabelVC.newLabel = self.labelName
        }
    }

}
