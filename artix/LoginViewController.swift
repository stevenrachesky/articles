//
//  LoginViewController.swift
//  artix
//
//  Created by Steven Rachesky on 4/1/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var ref = FIRDatabase.database().reference()
    
    let betaGroupCode = "HarvardBeta1"
    var rememberMeActive = false
    let inactiveImage = UIImage(named: "inactive checkbox")
    let activeImage = UIImage(named: "active checkbox")
    

    @IBOutlet weak var rememberMeImage: UIImageView!
    @IBOutlet weak var groupCode: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        rememberMeActive = UserDefaults.standard.bool(forKey: "isRememberMeActive")
        let name = UserDefaults.standard.string(forKey: "name")
        let group = UserDefaults.standard.string(forKey: "group")
        
        if (rememberMeActive == true)
        {
            fullName.text = UserDefaults.standard.string(forKey: "name")
            groupCode.text = UserDefaults.standard.string(forKey: "group")
            rememberMeImage.image = activeImage
        }
        else
        {
            fullName.text = ""
            groupCode.text = ""
            rememberMeImage.image = inactiveImage
        }
        
        // Automatic login
        if (rememberMeActive == true && fullName.text != "" && group == betaGroupCode)
        {
            print("HERE")
            rememberMeImage.image = activeImage
            
            // Perform Segue
            OperationQueue.main.addOperation {
                [weak self] in
                self?.performSegue(withIdentifier: "login", sender: self)
            }
        }
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rememberMeDidTouch(_ sender: Any) {
        
        if rememberMeActive == false
        {
            rememberMeImage.image = UIImage(named: "active checkbox")
            rememberMeActive = true
            
            UserDefaults.standard.set(fullName.text, forKey: "name")
            UserDefaults.standard.set(groupCode.text, forKey: "group")
            UserDefaults.standard.set(rememberMeActive, forKey: "isRememberMeActive")
        }
        else
        {
            rememberMeImage.image = UIImage(named: "inactive checkbox")
            rememberMeActive = false
            
            UserDefaults.standard.set(fullName.text, forKey: "name")
            UserDefaults.standard.set(groupCode.text, forKey: "group")
            UserDefaults.standard.set(rememberMeActive, forKey: "isRememberMeActive")
        }
    }
    @IBAction func joinDidTouch(_ sender: Any) {
        
        if rememberMeActive == true
        {
            UserDefaults.standard.set(fullName.text, forKey: "name")
            UserDefaults.standard.set(groupCode.text, forKey: "group")
            UserDefaults.standard.set(rememberMeActive, forKey: "isRememberMeActive")
        }
            
        if groupCode.text == betaGroupCode
        {
            //let post = ["fullName": fullName.text!, "personalList": ["key1":["Name" : "Name One", "url" :"Article One", "date": "Date"], "key2":["Name" : "Name Two", "url" :"Article Two", "date": "Date"], "key3": ["Name": "Name Three", "url" :"Article Three", "date": "Date"]], "groups": ["HarvardBeta1"]] as [String : Any]
            
            let post = ["fullName": fullName.text!, "personalList": [], "groups": ["HarvardBeta1"]] as [String : Any]
            
            
            
            self.ref.child("users").child(fullName.text!).setValue(post)
            performSegue(withIdentifier: "login", sender: sender)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
     
        return false
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "login"
        {
            let destVC = segue.destination as! MainTabBarController
            destVC.name = fullName.text!

        }
        
    }
    

}
