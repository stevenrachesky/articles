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
    var autoLogin = true
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet weak var rememberMeImage: UIImageView!
    @IBOutlet weak var groupCode: UITextField! // this is actually the password
    @IBOutlet weak var fullName: UITextField! // this is actually the email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
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
        if (rememberMeActive == true && fullName.text != "" && self.autoLogin == true)
        {
            rememberMeImage.image = activeImage
            
            FIRAuth.auth()?.signIn(withEmail: fullName.text!, password: groupCode.text!) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    print(error._code)
                    if (error._code == 17009)
                    {
                        let alert = UIAlertController(title: "Invalid password or email", message: "Please enter a valid password and email combination", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if (error._code == 17999)
                    {
                        let alert = UIAlertController(title: "Invalid password or email", message: "Please enter a valid password and email combination", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if (error._code == 17011)
                    {
                        let alert = UIAlertController(title: "Invalid password or email", message: "Please enter a valid password and email combination", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if (error._code == 17020)
                    {
                        let alert = UIAlertController(title: "No service", message: "OH is unable to verify your credentials due to a lack of reception", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return
                }
                
            
            
            // Perform Segue
            OperationQueue.main.addOperation {
                [weak self] in
                self?.performSegue(withIdentifier: "login", sender: self)
            }
                
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
            self.autoLogin = true
        }
            

        FIRAuth.auth()?.signIn(withEmail: fullName.text!, password: groupCode.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                print(error._code)
                if (error._code == 17009)
                {
                    let alert = UIAlertController(title: "Invalid password or email", message: "Please enter a valid password and email combination", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if (error._code == 17999)
                {
                    let alert = UIAlertController(title: "Invalid password or email", message: "Please enter a valid password and email combination", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if (error._code == 17011)
                {
                    let alert = UIAlertController(title: "Invalid password or email", message: "Please enter a valid password and email combination", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if (error._code == 17020)
                {
                    let alert = UIAlertController(title: "No service", message: "OH is unable to verify your credentials due to a lack of reception", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            

            self.performSegue(withIdentifier: "login", sender: sender)
            
            
            
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "login"
        {
            return false
        }
        
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "login"
        {
            let destVC = segue.destination as! MainTabBarController
            //destVC.name = fullName.text!

        }
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

}
