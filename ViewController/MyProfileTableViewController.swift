//
//  MyProfileTableViewController.swift
//  Todo
//
//  Created by IcyBlast on 27/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

protocol backNamePhotoProtocol_MyProfile_Menu
{
    func backnamePhotoFunc_MyProfile_Menu(name: String, photo: Data)
}

class MyProfileTableViewController: UITableViewController, backModifiedNameProtocol_UserName_MyProfile, backModifiedPhotoProtocol_UserPhoto_MyProfile
{
    @IBOutlet weak var MyProfileTableViewControllerUserPhotoUIImageView: UIImageView!
    
    @IBOutlet weak var MyProfileTableViewControllerUserNameUILabel: UILabel!
    
    var userName: String = ""
    var userPhoto: Data? = nil
    var userNamePhotoDelegate: backNamePhotoProtocol_MyProfile_Menu?
    
    func modifiedNameFunc_UserName_MyProfile(name: String)
    {
        self.userName = name
        self.MyProfileTableViewControllerUserNameUILabel.text = name
        self.tableView.reloadData()
    }
    
    func modifiedPhotoFunc_UserPhoto_MyProfile(photo: Data)
    {
        self.userPhoto = photo
        self.MyProfileTableViewControllerUserPhotoUIImageView.image = UIImage(data: photo)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configPhotoName()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.userNamePhotoDelegate?.backnamePhotoFunc_MyProfile_Menu(name: self.userName, photo: self.userPhoto!)
    }
    
    func configPhotoName()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(userName)'")
        do
        {
            let user = try context.fetch(fetchRequest) as! [UserInformation]
            self.MyProfileTableViewControllerUserNameUILabel.text = userName
            userPhoto = user.first?.value(forKey: "userPhoto") as? Data
            self.MyProfileTableViewControllerUserPhotoUIImageView.image = UIImage(data: userPhoto!)
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


    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1
        {
            let alertController = UIAlertController(title: "Logout will not delete any data. You can still log in with this account", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
                self.performSegue(withIdentifier: "logoutSegue", sender: self)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "logoutSegue"
        {
            let signInVC = segue.destination as! SignInViewController
            signInVC.logOutUserName = self.userName
        }
        else if segue.identifier == "userNameSegue"
        {
            let userNameNC = segue.destination as! UserNameNavigationController
            let userNameVC = userNameNC.topViewController as! UserNameTableViewController
            userNameVC.userNameDelegate = self
            userNameVC.userName = self.userName
        }
        else if segue.identifier == "userPhotoSegue"
        {
            let userPhotoVC = segue.destination as! UserPhotoViewController
            userPhotoVC.userName = self.userName
            userPhotoVC.userPhotoDelegate = self
            userPhotoVC.userPhoto = self.userPhoto
        }
    }
 

}
