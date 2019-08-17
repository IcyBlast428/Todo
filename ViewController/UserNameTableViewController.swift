//
//  UserNameTableViewController.swift
//  Todo
//
//  Created by IcyBlast on 27/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

protocol backModifiedNameProtocol_UserName_MyProfile
{
    func modifiedNameFunc_UserName_MyProfile(name: String)
}

class UserNameTableViewController: UITableViewController, UITextFieldDelegate
{
    
    var userNameDelegate: backModifiedNameProtocol_UserName_MyProfile?

    @IBOutlet weak var userNameTableViewCellNameTextField: UITextField!
    var userName = ""
    
    @IBAction func userNameTableViewControllerNavigationBarLeftButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userNameTableViewControllerNavigationBarRightButton(_ sender: Any)
    {
        //print(userNameTableViewCellNameTextField.text!)
        
        let modifiedUserName:String = userNameTableViewCellNameTextField.text!
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(userName)'")
        do
        {
            let user = try context.fetch(fetchRequest) as! [UserInformation]
            user.first?.userName = modifiedUserName
            try context.save()
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        self.userNameDelegate?.modifiedNameFunc_UserName_MyProfile(name: modifiedUserName)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        userNameTableViewCellNameTextField.delegate = self
        userNameTableViewCellNameTextField.text = userName
        userNameTableViewCellNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        userNameTableViewCellNameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        userNameTableViewCellNameTextField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 18
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    */
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! UserNameTableViewCell
        
        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
