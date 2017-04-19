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
   
    @IBOutlet var scrollView: UIScrollView!
    
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
        
        
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // scroll function
//    func adjustForKeyboard(notification: Notification) {
//        let userInfo = notification.userInfo!
//        print("1")
//        
//        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//        
//        if notification.name == Notification.Name.UIKeyboardWillHide {
//            self.scrollView.contentInset = UIEdgeInsets.zero
//        } else {
//            print("2")
//            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
//        }
//        
//        self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
//        
////        let selectedRange = self.scrollView.selectedRange
////        self.scrollView.scrollRangeToVisible(selectedRange)
//    }
    

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
        var phone_ = ""
        if self.number.text! != ""
        {
            phone_ = cleanPhoneNumber(phoneNumber: number.text!)
        }
        
        if fullName.text == ""
        {
            fullName.layer.borderColor = UIColor.red.cgColor
            fullName.layer.borderWidth = 1.0
            shouldSegue = false
        }
        
        if (phone_.length != 10 && Int(phone_) != nil) // ADD MORE ERROR CHECKING HERE
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
                    
                    var phoneNumber = self.cleanPhoneNumber(phoneNumber: self.number.text!)
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
                            
                            print("1.00")
                            
                            self.ref.child("phoneNumbers").child(phoneNumber).setValue(post_phone)
                            
                            print("2.00")
                            
                            for group in groupDict
                            {
                                let group_key = group.key as! String
                                let group_user_path = "groups/" + group_key + "/members/" + (FIRAuth.auth()?.currentUser!.uid)!
                                
                                self.ref.child(group_user_path).setValue(self.fullName.text!)
                            }
                            
                            self.performSegue(withIdentifier: "join", sender: self)
                            
                        })
                    }
                    else
                    {
                        // new user
                        let post_user = ["fullName": self.fullName.text!, "phoneNumber": phoneNumber, "email" : self.email.text!, "password": self.password.text!, "personalList": [], "groups": []] as [String : Any]
                        
                        let post_phone = ["userID" : (FIRAuth.auth()?.currentUser!.uid)!]
                        
                        self.ref.child("users").child((FIRAuth.auth()?.currentUser!.uid)!).setValue(post_user)
                        
                        self.ref.child("phoneNumbers").child(phoneNumber).setValue(post_phone)
                        
                        self.performSegue(withIdentifier: "join", sender: self)
                    }

                })
                
                
            
                
            }
            
            
        }
        
    }
    
    func cleanPhoneNumber(phoneNumber: String) -> String
    {
        var number = phoneNumber
        
        number = number.trimmingCharacters(in: NSCharacterSet(charactersIn: "+") as CharacterSet)
        let first_character = number.substring(to: number.index(after: number.startIndex))
        if first_character == "1"
        {
            number.remove(at: number.startIndex)
        }
        
        if number.contains("(")
        {
            number = number.replacingOccurrences(of: "(", with: "")
        }
        
        if number.contains(")")
        {
            number = number.replacingOccurrences(of: ")", with: "")
        }
        
        if number.contains("-")
        {
            number = number.replacingOccurrences(of: "-", with: "")
        }
        
        if number.contains(" ")
        {
            number = number.replacingOccurrences(of: " ", with: "")
        }
        
        return number
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
