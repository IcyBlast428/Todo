//
//  MainViewController.swift
//  Todo
//
//  Created by IcyBlast on 26/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, backProtocol_Menu_Main//, backChangedLabelProtocol_ChangeLabel_Main
{
    @IBOutlet weak var mainViewControllerToolbar: UIToolbar!
    @IBOutlet weak var mainViewControllerTableView: UITableView!
    @IBOutlet weak var mainViewControllerAddToDoTextField: UITextField!
    @IBOutlet weak var mainViewControllerNavigationItem: UINavigationItem!
    
    var userName: String = ""   // which users login
    var mainLabel: String = ""  // label in this pages
    var eventList: [UserEvents] = []    //
    var backDelegate: backProtocol_Menu_Main?
    var selectedEvent: String = ""
    
    func backNameFunc_Menu_Main(name: String)
    {
        self.userName = name
    }
    func backLabelFunc_Menu_Main(label: String)
    {
        self.mainLabel = label
        self.mainViewControllerNavigationItem.title = self.mainLabel
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")    // UserLabels table
        fetchRequest.predicate = NSPredicate(format: "labelName = '\(mainLabel)'")
        do
        {
            let label = try context.fetch(fetchRequest) as! [UserLabels]
            for i in label
            {
                if i.users?.userName == self.userName
                {
                    eventList = i.events?.allObjects as! [UserEvents]
                }
            }
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        mainViewControllerTableView.reloadData()
    }
    
    // change the Status bar style to default
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .default
    }
    
    // initialize the tool bar
    func configMainViewControllerToolbar()
    {
        self.mainViewControllerAddToDoTextField.delegate = self
        self.mainViewControllerToolbar.frame.origin.x = 0
        self.mainViewControllerToolbar.frame.origin.y = self.view.frame.height - self.mainViewControllerToolbar.frame.height
        self.mainViewControllerToolbar.backgroundColor = UIColor.white
        self.view.addSubview(mainViewControllerToolbar)
    }
    
    // initialize the table view (dataSource, delegate)
    func configMainViewControllerTableView()
    {
        self.mainViewControllerTableView.delegate = self
        self.mainViewControllerTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    // when view loaded
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configMainViewControllerTableView() // call the initial function of table view
        configMainViewControllerToolbar()   // call the initial function of tool bar
        
        mainLabel = "To-Do"                                                 //set the default label
        self.mainViewControllerNavigationItem.title = self.mainLabel
        
        // set the key board observer (keyboard show and hide)
        NotificationCenter.default.addObserver(self, selector: #selector(UIKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(UIKeyboardWillHiden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleTap(sender:))))
    }
    
    // view will load
    override func viewWillAppear(_ animated: Bool)
    {
        // get the database
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")    // UserLabels table
        fetchRequest.predicate = NSPredicate(format: "labelName = '\(mainLabel)'")  // where labelName = mainLabel
        do
        {
            let label = try context.fetch(fetchRequest) as! [UserLabels]
            for i in label
            {
                if i.users?.userName == self.userName
                {
                    eventList = i.events?.allObjects as! [UserEvents]
                }
            }
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        
        mainViewControllerTableView.reloadData() // reload the table view data
    }
 
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @objc func UIKeyboardWillShow(notification: NSNotification)
    {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue
        let height = keyboardRec?.size.height
        UITextView.animate(withDuration: 0.1, animations: {
            self.mainViewControllerToolbar.frame.origin.y -= height!    // tool bar move up
        })
    }
    
    @objc func UIKeyboardWillHiden(notification: NSNotification)
    {
        UITextView.animate(withDuration: 0.1, animations: {
            self.mainViewControllerToolbar.frame.origin.y = self.view.frame.height - self.mainViewControllerToolbar.frame.height    // tool bar move down
        })
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        if sender.state == .ended {
            mainViewControllerAddToDoTextField.resignFirstResponder()   // text field of tool bar loose responder, hide the key board
        }
        sender.cancelsTouchesInView = false
    }
    
    // type enter on the key board, and add new event in the database
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        let event: String = mainViewControllerAddToDoTextField.text!
        if event != ""
        {
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext as NSManagedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")    // UserLabels table
            fetchRequest.predicate = NSPredicate(format: "labelName = '\(mainLabel)'")
            do
            {
                let label = try context.fetch(fetchRequest) as! [UserLabels]
                for i in label
                {
                    if i.users?.userName == self.userName
                    {
                        let newEvent = NSEntityDescription.insertNewObject(forEntityName: "UserEvents", into: context) as! UserEvents
                        newEvent.eventsName = event
                        let timeInterval:TimeInterval = TimeInterval(0) // time interval is 0
                        newEvent.eventsDate = NSDate(timeIntervalSince1970: timeInterval)   //set remind time of the event date to 1970/01/01 00:00:00
                        newEvent.eventsPlace = ""   // set the remind place of the event to ""
                        newEvent.eventsNote = "Add a note"  // set the note of the event to "Add a note"
                        i.addToEvents(newEvent) // add relationships between label and event
                        try context.save()  //write into database
                        eventList.append(newEvent)
                    }
                }
            }
            catch
            {
                fatalError("Error：\(error)")
            }
        }
        mainViewControllerAddToDoTextField.text = ""    // clear the tool bar input field
        mainViewControllerAddToDoTextField.resignFirstResponder()   // hide key board
        mainViewControllerTableView.reloadData()    // refresh the table view data
        return true
    }
    
    // return the number of event under the event
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.isEqual(self.mainViewControllerTableView)
        {
            return eventList.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var identifier = ""
        
        if tableView.isEqual(self.mainViewControllerTableView)
        {
            identifier = "MainViewTableViewCell"    // cell identifier
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as UITableViewCell
        
        if tableView.isEqual(self.mainViewControllerTableView)
        {
            cell.textLabel?.text = eventList[indexPath.row].eventsName  // set the cell label to event name
        }
        return cell
    }
    
    // height of each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView.isEqual(self.mainViewControllerTableView)
        {
            return 64
        }
        return 64
    }
    
    // deselect each cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.isEqual(self.mainViewControllerTableView)
        {
            mainViewControllerTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // segue transfer data between different pages
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "mainViewToMenuViewSugue"    // to Menu view controller
        {
            let navController = segue.destination as! MyProfileNavigationController
            let menuTableViewController = navController.topViewController as! MenuTableViewController
            menuTableViewController.backDelegate = self
            menuTableViewController.userName = self.userName
        }
        else if segue.identifier == "mainToDetailsSegue"    // to detail view controller
        {
            let detailsVC = segue.destination as! DetailsTableViewController
            detailsVC.userName = self.userName
            detailsVC.labelName = self.mainLabel
            detailsVC.eventName = eventList[(self.mainViewControllerTableView.indexPathForSelectedRow?.row)!].eventsName!
        }
    }
    

}
