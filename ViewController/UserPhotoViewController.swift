//
//  UserPhotoViewController.swift
//  Todo
//
//  Created by IcyBlast on 26/5/18.
//  Copyright © 2018 IcyBlast. All rights reserved.
//

import UIKit
import CoreData

protocol backModifiedPhotoProtocol_UserPhoto_MyProfile
{
    func modifiedPhotoFunc_UserPhoto_MyProfile(photo: Data)
}

class UserPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var userPhotoViewControllerUIImageView: UIImageView!
    
    var userName: String = ""
    var userPhoto: Data? = nil
    var userPhotoDelegate: backModifiedPhotoProtocol_UserPhoto_MyProfile?
    
    @IBAction func userPhotoViewControllerNavigationBarRightButton(_ sender: Any)
    {
        let alertController = UIAlertController()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let takeAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.camera()
        })
        let chooseAction = UIAlertAction(title: "Choose from Album", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.photo()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(takeAction)
        alertController.addAction(chooseAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func camera()
    {
        let pick:UIImagePickerController = UIImagePickerController()
        pick.delegate = self
        pick.sourceType = UIImagePickerControllerSourceType.camera
        pick.allowsEditing = true
        self.present(pick, animated: true, completion: nil)
    }
    
    func photo()
    {
        let pick:UIImagePickerController = UIImagePickerController()
        pick.delegate = self
        pick.sourceType = UIImagePickerControllerSourceType.photoLibrary
        pick.allowsEditing = true
        self.present(pick, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let imagePickerc = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImagePNGRepresentation(imagePickerc)! as NSData
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext as NSManagedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserInformation")
        fetchRequest.predicate = NSPredicate(format: "userName = '\(userName)'")
        do
        {
            let user = try context.fetch(fetchRequest) as! [UserInformation]
            user.first?.userPhoto = imageData
            try context.save()
        }
        catch
        {
            fatalError("Error：\(error)")
        }
        self.userPhotoDelegate?.modifiedPhotoFunc_UserPhoto_MyProfile(photo: imageData as Data)
        self.userPhotoViewControllerUIImageView.image = imagePickerc
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.userPhotoViewControllerUIImageView.image = UIImage(data: self.userPhoto!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
