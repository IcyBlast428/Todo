//
//  menuTableViewController.swift
//  Todo
//
//  Created by IcyBlast on 28/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

protocol backProtocol_Menu_Main
{
    func backNameFunc_Menu_Main(name: String)
    func backLabelFunc_Menu_Main(label: String)
}

class MenuTableViewController: UITableViewController, backNamePhotoProtocol_MyProfile_Menu
{
    func backnamePhotoFunc_MyProfile_Menu(name: String, photo: Data)
    {
        self.userName = name
        MenuTableViewControllerUserPhotoUIImageView.image = UIImage(data: photo)
        MenuTableViewControllerUserNameUILabel.text = name
    }
    
    @IBAction func MenuTableViewControllerNavigationRightButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var MenuTableViewControllerUserPhotoUIImageView: UIImageView!
    @IBOutlet weak var MenuTableViewControllerUserNameUILabel: UILabel!
    
    var userName: String = ""
    var labelList: [UserLabels] = []
    var backDelegate: backProtocol_Menu_Main?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "labelCell")
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(userName)'")
        do
        {
            let user = try context.fetch(fetchRequest) as! [UserInformation]
            //print(user.count)
            MenuTableViewControllerUserNameUILabel.text = userName
            MenuTableViewControllerUserPhotoUIImageView.image = UIImage(data: user.first?.value(forKey: "userPhoto") as! Data)
            labelList = user.first?.labels?.allObjects as! [UserLabels]
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.backDelegate?.backNameFunc_Menu_Main(name: self.userName)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 2
        }
        else if section == 1
        {
            return labelList.count
        }
        else if section == 2
        {
            return 1
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
            cell.textLabel?.text = labelList[indexPath.row].labelName
            return cell
        }
        else
        {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 1
        {
            return 44
        }
        else
        {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    {
        if indexPath.section == 1
        {
            let newIndexPath = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
        }
        else
        {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0   // user information, photo and name
        {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else if indexPath.section == 1  // select label
        {
            tableView.deselectRow(at: indexPath, animated: true)
            self.backDelegate?.backLabelFunc_Menu_Main(label: labelList[indexPath.row].labelName!)
            dismiss(animated: true, completion: nil)
        }
        else if indexPath.section == 2  // insert new label
        {
            tableView.deselectRow(at: indexPath, animated: true)
            var inputNewList = UITextField()
            let alertController = UIAlertController(title: "Add New List", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addTextField { (textField:UITextField) -> Void in
                inputNewList = textField
                inputNewList.placeholder = "list title"
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
                
                self.insertDefaultLabel(labelName: inputNewList.text!)
                self.tableView.insertRows(at: [IndexPath(row: self.labelList.count - 1, section: 1)], with: .automatic)
                self.tableView.reloadSections([1], with: .automatic)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func insertDefaultLabel(labelName: String)
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(self.userName)'")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserInformation]
            let user = fetchedObjects.first
            
            let newLabel = NSEntityDescription.insertNewObject(forEntityName: "UserLabels", into: context) as! UserLabels
            newLabel.labelName = labelName
            
            user?.addToLabels(newLabel)
            
            try context.save()
            labelList.append(newLabel)
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if indexPath.section == 1 && tableView.cellForRow(at: indexPath)?.textLabel?.text != "To-Do"
        {
            return true
        }
        else
        {
            return false
        }
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let deletedLabel = labelList.remove(at: indexPath.row)
            
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext as NSManagedObjectContext
            
            let user = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
            user.predicate = NSPredicate(format: "userName = '\(self.userName)'")
            do
            {
                let userList = try context.fetch(user) as! [UserInformation]
                userList.first?.removeFromLabels(deletedLabel)
                context.delete(deletedLabel)
                try context.save()
            }
            catch
            {
                fatalError()
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadSections([1], with: .automatic)
        }
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "menuToMyProfileSegue"
        {
            let myProfileVC = segue.destination as! MyProfileTableViewController
            myProfileVC.userNamePhotoDelegate = self
            myProfileVC.userName = self.userName
        }
    }
 

}
