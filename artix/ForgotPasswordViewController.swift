//
//  ForgotPasswordViewController.swift
//  artix
//
//  Created by Steven Rachesky on 4/18/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {


    @IBOutlet weak var email: DesignableTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetDidTouch(sender: AnyObject) {
        
        email.borderColor = UIColor(red:140/255.0, green:178/255.0, blue:236/255.0, alpha: 1.0)

        if email.text == ""
        {
            email.borderColor = UIColor.red
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a proper email", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            //send new password to user
            let email_ = email.text!
            FIRAuth.auth()?.sendPasswordReset(withEmail: email_) { error in
                if (error != nil){
                    self.email.borderColor = UIColor.red
                    // An error happened.
                    print(error?._code)
                    switch (error!._code) {
                    //Invalid Email
                    case 17999:
                        let alert = UIAlertController(title: "Invalid Email", message: "Please enter a proper email registered with Artix", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break;
                    case 17011:
                        let alert = UIAlertController(title: "Invalid Email", message: "Please enter a proper email registered with Artix", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case 17020:
                        let alert = UIAlertController(title: "No service", message: "Artix is unable to verify your credentials due to a lack of service", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break;
                    default:
                        break;
                    }
                }
                else
                {
                    // Password reset email sent.
                    self.performSegue(withIdentifier: "reset", sender: self)
                   // self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "reset"
        {
            let destVC = segue.destination as! LoginViewController
            destVC.autoLogin = false
        }
    }
    
}
