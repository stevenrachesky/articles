//
//  GroupListTableViewController.swift
//  artix
//
//  Created by Steven Rachesky on 3/27/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class GroupListTableViewController: UITableViewController {
    
    var userGroups : [String] = []
    var userGroupsKeys : [String] = []
    var name = ""
    var userID = FIRAuth.auth()?.currentUser?.uid
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        print("Group list: ")
        print(name)
        
        let path = "users/" + userID! + "/groups"
        
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() == true
            {
                let snapDict = snapshot.value as! NSDictionary
                self.userGroups = snapDict.allValues as! [String]
                self.userGroupsKeys = snapDict.allKeys as! [String]
            }
            else
            {
                let alert = UIAlertController(title: "No Groups", message: "Sorry, we did not find any groups that you belonged to!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            //print(self.userGroups)
            self.tableView.reloadData()
            
        
        })
        
        if name == ""
        {
            let user_name_path = "users/" + userID! + "/fullName"
            self.ref.child(user_name_path).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot.value as! String)
                self.name = snapshot.value! as! String
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.userGroups.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath)
        
        cell.textLabel?.text! = self.userGroups[(indexPath as NSIndexPath).item]
        cell.textLabel?.tag = (indexPath as NSIndexPath).row
        cell.tag = (indexPath as NSIndexPath).row


        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let more = UITableViewRowAction(style: .normal, title: "Add\nmember") { action, index in
            print("more button tapped")
            
//            let path = "users/" + self.userID! + "/personalList"
//            
//            let date = Date()
//            print(date)
//            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
//            let dateString = dateFormatter.string(from: date)
//            
//            let post = ["Name": self.articlesName[(index as NSIndexPath).item], "url":self.articlesURL[(index as NSIndexPath).item], "date": dateString, "title":self.articlesTitle[(index as NSIndexPath).item]]
//            
//            self.ref.child(path).childByAutoId().setValue(post)
            
            tableView.setEditing(false, animated: true)
            
        }
        more.backgroundColor = UIColor(red: 2.0/255.0, green: 179.0/255.0, blue: 1.0, alpha: 1.0)
        
        let leave = UITableViewRowAction(style: .normal, title: "Leave\ngroup") { action, index in
            print("leave button tapped")
            
            
            tableView.setEditing(false, animated: true)
            
        }
        leave.backgroundColor = UIColor(red: 249.0/255.0, green: 24.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped")
            
            
            tableView.setEditing(false, animated: true)
            
        }
        edit.backgroundColor = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        
        
        
        return [more, leave, edit]
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "groupTouch"
        {
            let destVC = segue.destination as! ArticleViewController
            destVC.name = self.name
            
            let buttonRow = (sender! as AnyObject).tag
            destVC.group = self.userGroupsKeys[buttonRow!] 
            
        }
    }
    

}
