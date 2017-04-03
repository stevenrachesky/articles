//
//  MainTabBarController.swift
//  artix
//
//  Created by Steven Rachesky on 4/1/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Main Tab: ")
        print(name)
        
        let barViewControllers = self.viewControllers
        let groupNav = barViewControllers![1] as! UINavigationController
        let groupList = groupNav.topViewController as! GroupListTableViewController
        groupList.name = self.name

        let perosnalNav = barViewControllers![0] as! UINavigationController
        let personalList = perosnalNav.topViewController as! PersonalListTableViewController
        personalList.name = self.name
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
