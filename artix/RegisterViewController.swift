//
//  RegisterViewController.swift
//  artix
//
//  Created by Steven Rachesky on 4/8/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase


class RegisterViewController: UIViewController {

    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var email: UITextField!
   
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func fullNameEditingChanged(_ sender: Any) {
        
        fullName.layer.borderColor = nil
        fullName.layer.borderWidth = 0.0
    }
    

    @IBAction func numberEditingChanged(_ sender: Any) {
        
        number.layer.borderColor = nil
        number.layer.borderWidth = 0.0
    }
    
    @IBAction func emailEditingChanged(_ sender: Any) {
        
        email.layer.borderColor = nil
        email.layer.borderWidth = 0.0
    }
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        
        password.layer.borderColor = nil
        password.layer.borderWidth = 0.0
    }
    
    @IBAction func confirmPasswordEditingChanged(_ sender: Any) {
        
        confirmPassword.layer.borderColor = nil
        confirmPassword.layer.borderWidth = 0.0
    }
    
    @IBAction func joinDidTouch(_ sender: Any) {
        
        var shouldSegue = true
        
        if fullName.text == ""
        {
            fullName.layer.borderColor = UIColor.red.cgColor
            fullName.layer.borderWidth = 1.0
            shouldSegue = false
        }
        
        if (number.text! == "") // ADD MORE ERROR CHECKING HERE
        {
            number.layer.borderColor = UIColor.red.cgColor
            number.layer.borderWidth = 1.0
            shouldSegue = false
        }
        
        if email.text == ""
        {
            email.layer.borderColor = UIColor.red.cgColor
            email.layer.borderWidth = 1.0
            shouldSegue = false
        }
        
        if password.text == ""
        {
            password.layer.borderColor = UIColor.red.cgColor
            password.layer.borderWidth = 1.0
            shouldSegue = false
        }
        
        if (confirmPassword.text == "" || confirmPassword.text != password.text)
        {
            confirmPassword.layer.borderColor = UIColor.red.cgColor
            confirmPassword.layer.borderWidth = 1.0
            shouldSegue = false
        }
        
        if shouldSegue == true
        {
            //create user
            FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    switch (error._code) {
                    //Taken Email
                    case 17007:
                        let alert = UIAlertController(title: "Email already in use", message: "Please enter a different email", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break;
                    //Invalid Email
                    case 17999:
                        let alert = UIAlertController(title: "Invalid Email", message: "Please enter a proper email", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break;
                    case 17011:
                        let alert = UIAlertController(title: "Invalid Email", message: "Please enter a proper email", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break;
                    default:
                        break;
                    }
                    return
                }
                
                // Check if phone number already listed
                self.ref.child("phoneNumbers").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // clean phone numbrer
                    var phoneNumber = self.number.text!
                    phoneNumber = phoneNumber.trimmingCharacters(in: NSCharacterSet(charactersIn: "+") as CharacterSet)
                    let first_character = phoneNumber.substring(to: phoneNumber.index(after: phoneNumber.startIndex))
                    if first_character == "1"
                    {
                        phoneNumber.remove(at: phoneNumber.startIndex)
                    }
                    print(phoneNumber)
                    
                    if snapshot.hasChild(phoneNumber)
                    {
                        // user already invited
                        let new_user_phone_path = "phoneNumbers/" + phoneNumber + "/groups"
                        self.ref.child(new_user_phone_path).observeSingleEvent(of: .value, with: { (snapshot) in
                            var groupDict = snapshot.value as! NSDictionary
                            
                            let post_user = ["fullName": self.fullName.text!, "phoneNumber": phoneNumber, "email" : self.email.text!, "password": self.password.text!, "personalList": [], "groups": groupDict] as [String : Any]
                            
                            let post_phone = ["userID" : (FIRAuth.auth()?.currentUser!.uid)!]
                            
                            self.ref.child("users").child((FIRAuth.auth()?.currentUser!.uid)!).setValue(post_user)
                            
                            self.ref.child("phoneNumbers").child(phoneNumber).setValue(post_phone)
                            
                        })
                    }
                    else
                    {
                        // new user
                        let post_user = ["fullName": self.fullName.text!, "phoneNumber": phoneNumber, "email" : self.email.text!, "password": self.password.text!, "personalList": [], "groups": []] as [String : Any]
                        
                        let post_phone = ["userID" : (FIRAuth.auth()?.currentUser!.uid)!]
                        
                        self.ref.child("users").child((FIRAuth.auth()?.currentUser!.uid)!).setValue(post_user)
                        
                        self.ref.child("phoneNumbers").child(phoneNumber).setValue(post_phone)
                        
                        
                    }
                    
                    self.performSegue(withIdentifier: "join", sender: self)
                })
                
                
            
                
            }
            
            
        }
        
    }
    
    

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
