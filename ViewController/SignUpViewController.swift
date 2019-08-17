//
//  SignUpViewController.swift
//  Todo
//
//  Created by IcyBlast on 1/6/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

// add under line for text field
extension UITextField
{
    func setBottomBorder()
    {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

class SignUpViewController: UIViewController, UITextFieldDelegate
{
    /*
    // generate random User ID
    func getRandomStringOfLength() -> String
    {
        var randomStr = ""
        for _ in 1 ... 10{
            let num = 48 + arc4random() % 74
            let randomCharacter = Character(UnicodeScalar(num)!)
            randomStr.append(randomCharacter)
        }
        return "userid_" + randomStr
    }*/

    @IBAction func SignUpViewControllerBackButton(_ sender: Any)
    {
        self.SignUpViewControllerUserNameTextField.resignFirstResponder()
        self.SignUpViewControllerPasswordTextField.resignFirstResponder()
        self.SignUpViewControllerVerifyPasswordTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var SignUpViewControllerUserNameTextField: UITextField!
    
    @IBOutlet weak var SignUpViewControllerPasswordTextField: UITextField!
    
    @IBOutlet weak var SignUpViewControllerVerifyPasswordTextField: UITextField!
    
    @IBOutlet weak var SignUpViewControllerSubmitButton: UIButton!
    
    func configSubmitButton()
    {
        SignUpViewControllerSubmitButton.layer.cornerRadius = 4
        SignUpViewControllerSubmitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }
    
    @objc func submit()
    {
        let username:String = self.SignUpViewControllerUserNameTextField.text!
        let password:String = self.SignUpViewControllerPasswordTextField.text!
        let verifyPassword:String = self.SignUpViewControllerVerifyPasswordTextField.text!
        
        if username != "" && password != "" && verifyPassword != ""
        {
            if password != verifyPassword
            {
                let alertPasswordVerify = UIAlertController(title: "Incorrect Confirm Password!", message: "The passwords you entered do not match.", preferredStyle: UIAlertControllerStyle.alert)
                alertPasswordVerify.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertPasswordVerify, animated: true, completion: nil)
            }
            else
            {
                let app = UIApplication.shared.delegate as! AppDelegate
                let context = app.persistentContainer.viewContext as NSManagedObjectContext
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
                fetchRequest.predicate = NSPredicate.init(format: "userName = '\(username)'")
                
                do
                {
                    let result = try context.fetch(fetchRequest)
                    if result.count == 0
                    {
                        
                        let alertController = UIAlertController(title: "Create Account?", message: "Are you sure you wish to create this account?", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.default, handler: {
                            action in
                            
                            let app = UIApplication.shared.delegate as! AppDelegate
                            let context = app.persistentContainer.viewContext as NSManagedObjectContext
                            let user = NSEntityDescription.insertNewObject(forEntityName: "UserInformation", into: context) as! UserInformation
                            
                            user.userName = username
                            user.userPassword = verifyPassword
                            user.userPhoto = UIImagePNGRepresentation(UIImage(named: "defaultUserPhoto.jpg")!)! as NSData
                            
                            do
                            {
                                try context.save()
                            }
                            catch let error
                            {
                                fatalError("Error：\(error)")
                            }
                            self.insertDefaultLabel(userName: username)
                            self.dismiss(animated: true, completion: nil)
                            self.dismiss(animated: true, completion: nil)
                            //self.navigationController?.popToRootViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    else
                    {
                        let alertPasswordVerify = UIAlertController(title: "Incorrect Username!", message: "There is a exist user called \(username), please use a different name.", preferredStyle: UIAlertControllerStyle.alert)
                        alertPasswordVerify.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alertPasswordVerify, animated: true, completion: nil)
                    }
                }
                catch
                {
                    print("Failed")
                }
                
            }
        }
        else
        {
            let alertPasswordVerify = UIAlertController(title: "Alert!", message: "All fields must be filled in!", preferredStyle: UIAlertControllerStyle.alert)
            alertPasswordVerify.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertPasswordVerify, animated: true, completion: nil)
        }
        
    }
    
    func insertDefaultLabel(userName: String)
    {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(userName)'")
        do
        {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserInformation]
            let user = fetchedObjects.first
            
            print((user?.labels?.count)!)
            if (user?.labels?.count)! == 0
            {
                let defaultLabel = NSEntityDescription.insertNewObject(forEntityName: "UserLabels", into: context) as! UserLabels
                defaultLabel.labelName = "To-Do"
                user?.addToLabels(defaultLabel)
                do
                {
                    try context.save()
                }
                catch let error
                {
                    fatalError("Error：\(error)")
                }
            }
            print((user?.labels?.count)!)
        }
        catch
        {
            fatalError("Error：\(error)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func confitTextField()
    {
        SignUpViewControllerUserNameTextField.setBottomBorder()
        SignUpViewControllerUserNameTextField.delegate = self
        SignUpViewControllerUserNameTextField.returnKeyType = UIReturnKeyType.done
        
        SignUpViewControllerPasswordTextField.setBottomBorder()
        SignUpViewControllerPasswordTextField.delegate = self
        SignUpViewControllerPasswordTextField.returnKeyType = UIReturnKeyType.done
        
        SignUpViewControllerVerifyPasswordTextField.setBottomBorder()
        SignUpViewControllerVerifyPasswordTextField.delegate = self
        SignUpViewControllerVerifyPasswordTextField.returnKeyType = UIReturnKeyType.done
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configSubmitButton()
        confitTextField()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
}
