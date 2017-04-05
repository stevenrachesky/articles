//
//  AddArticleViewController.swift
//  artix
//
//  Created by Steven Rachesky on 4/1/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class AddArticleViewController: UIViewController {

    var group = ""
    var name = ""
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var urlTextField: DesignableTextField!
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
    

    @IBAction func addDidTouch(_ sender: Any) {
        
        let path = "groups/" + self.group
        
        let date = Date()
        print(date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        let dateString = dateFormatter.string(from: date)
        
        if urlTextField.text! != ""
        {
        
            let post = ["Name": self.name, "url":self.urlTextField.text!, "date": dateString]
        
            self.ref.child(path).childByAutoId().setValue(post)
            
            
            

        }
        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "unwindAdd")
        {
            print("Entered")
            let destVC = segue.destination as! ArticleListTableViewController
            destVC.name = self.name
            destVC.group = self.group
            destVC.tableView.reloadData()
            destVC.viewWillAppear(true)
            destVC.viewDidLoad()
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

}
