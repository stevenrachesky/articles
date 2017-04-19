//
//  MainTabBarController.swift
//  artix
//
//  Created by Steven Rachesky on 4/1/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    
    var name = ""
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()
    var userID = FIRAuth.auth()?.currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Main Tab: ")
       // print(name)
        
        let path = "users/" + userID!

        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let barViewControllers = self.viewControllers
            let groupNav = barViewControllers![1] as! UINavigationController
            let groupList = groupNav.topViewController as! GroupListTableViewController
            self.name = (snapshot.value! as! NSDictionary)["fullName"]! as! String //bug here
            groupList.name = self.name
            
            let perosnalNav = barViewControllers![0] as! UINavigationController
            let personalList = perosnalNav.topViewController as! PersonalListTableViewController
            personalList.name = self.name
            
        })
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "login"
//        {
//            let destVC = segue.destination as! GroupNavigationViewController
//            destVC.name = self.name
//            
//        }
    }
    

}
