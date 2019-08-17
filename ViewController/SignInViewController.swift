//
//  SignInViewController.swift
//  Todo
//
//  Created by IcyBlast on 1/6/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController, UITextFieldDelegate
{
    
    var logOutUserName:String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .default
    }

    @IBOutlet weak var SignInViewControllerSignInButton: UIButton!
    
    @IBOutlet weak var SignInViewControllerUserNameTextField: UITextField!
    
    @IBOutlet weak var SignInViewControllerPasswordTextField: UITextField!
    
    @IBAction func SignInViewControllerSignUpButton(_ sender: Any)
    {
        self.SignInViewControllerUserNameTextField.text = ""
        self.SignInViewControllerPasswordTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func configButton()
    {
        SignInViewControllerSignInButton.layer.cornerRadius = 4
        SignInViewControllerSignInButton.addTarget(self, action: #selector(signin), for: .touchUpInside)
    }
    
    func configTextField()
    {
        SignInViewControllerUserNameTextField.setBottomBorder()
        SignInViewControllerUserNameTextField.delegate = self
        SignInViewControllerUserNameTextField.returnKeyType = UIReturnKeyType.done
        SignInViewControllerPasswordTextField.setBottomBorder()
        SignInViewControllerPasswordTextField.delegate = self
        SignInViewControllerPasswordTextField.returnKeyType = UIReturnKeyType.done
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.SignInViewControllerUserNameTextField.resignFirstResponder()
        self.SignInViewControllerPasswordTextField.resignFirstResponder()
    }
    
    
    
    @IBOutlet weak var userPhoto: UIImageView!
    
    required init?(coder aDecoder: NSCoder)
    {
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configButton()
        configTextField()
        
        if logOutUserName != ""
        {
            self.SignInViewControllerUserNameTextField.text = logOutUserName
        }
    }
    
    func showData()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest)
            for info in fetchedObjects
            {
                print("User Name: \(info.value(forKey: "userName") as! String)")
                print("User Password: \(info.value(forKey: "userPassword") as! String)")
                userPhoto.image = UIImage(data: info.value(forKey: "userPhoto") as! Data)
            }
            print("\n")
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserLabels]
            for info in fetchedObjects
            {
                print(info.labelName!, (info.users?.userName)!)
                
            }
            print("\n")
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        
        fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserEvents]
            for info in fetchedObjects
            {
                print(info.eventsName!, (info.labels?.labelName)!, (info.labels?.users?.userName)!)
            }
            print("\n")
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }
    
    func deleteLabel()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let label = NSFetchRequest<NSManagedObject>(entityName: "UserLabels")
        do
        {
            let labelList = try context.fetch(label) as! [UserLabels]
            
            for label in labelList
            {
                print((label.users?.userName)!)
                context.delete(label)
            }
            try context.save()
            print(labelList.count)
        }
        catch
        {
            fatalError()
        }
    }
    
    func deleteEvent()
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let events = NSFetchRequest<NSManagedObject>(entityName: "UserEvents")
        do
        {
            let eventsList = try context.fetch(events) as! [UserEvents]
            
            for event in eventsList
            {
                context.delete(event)
                
            }
            try context.save()
            print(eventsList.count)
        }
        catch
        {
            fatalError()
        }
    }
    
    @objc func signin()
    {
        let username:String = self.SignInViewControllerUserNameTextField.text!
        let password:String = self.SignInViewControllerPasswordTextField.text!
        if username != "" && password != ""
        {
            
            let app = UIApplication.shared.delegate as! AppDelegate
            let context = app.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
            fetchRequest.predicate = NSPredicate.init(format: "userName = '\(username)'")
            do
            {
                let result = try context.fetch(fetchRequest)
                if result.count == 0
                {
                    let alertPasswordVerify = UIAlertController(title: "Incorrect Username!", message: "No user called \(username)", preferredStyle: UIAlertControllerStyle.alert)
                    alertPasswordVerify.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alertPasswordVerify, animated: true, completion: nil)
                }
                else
                {
                    if (result.first?.value(forKey: "userPassword") as! String) == password
                    {
                        /*-------------------------------------------------  Login Success  -------------------------------------------------*/
                        self.performSegue(withIdentifier: "mainViewControllerSegue", sender: self)
                    }
                    else
                    {
                        let alertPasswordVerify = UIAlertController(title: "Incorrect Password!", message: "The password you entered do not match.", preferredStyle: UIAlertControllerStyle.alert)
                        alertPasswordVerify.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alertPasswordVerify, animated: true, completion: nil)
                    }
                }
            }
            catch
            {
                print("Failed")
            }
        }
        else
        {
            let alertPasswordVerify = UIAlertController(title: "Alert!", message: "User Name or Password cannot be null!", preferredStyle: UIAlertControllerStyle.alert)
            alertPasswordVerify.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertPasswordVerify, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "mainViewControllerSegue")
        {
            let navController = segue.destination as! UINavigationController
            let mainController = navController.topViewController as! MainViewController
            mainController.userName = self.SignInViewControllerUserNameTextField.text!
        }
    }
    
}
