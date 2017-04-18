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
    var indexOfRowSwipe = 0
    
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
            
            self.indexOfRowSwipe = index.row
            
            self.performSegue(withIdentifier: "addMember", sender: self)
            
            print("segue performed")
            
            tableView.setEditing(false, animated: true)
            
        }
        more.backgroundColor = UIColor(red: 2.0/255.0, green: 179.0/255.0, blue: 1.0, alpha: 1.0)
        
        let leave = UITableViewRowAction(style: .normal, title: "Leave\ngroup") { action, index in
            print("leave button tapped at \(index.row)")
            
            let groupKey = self.userGroupsKeys[index.row]
            
            let user_group_path = "users/" + self.userID! + "/groups/" + groupKey
            
            let group_user_path = "groups/" + groupKey + "/members/" + self.userID!
            
            let confirmAlert = UIAlertController(title: "Are you sure?", message: "You will lose access to this group.", preferredStyle: UIAlertControllerStyle.alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                // Yes leave group
                print("Handle Yes logic here")
                
                self.userGroupsKeys.remove(at: index.row)
                self.userGroups.remove(at: index.row)
                
                self.ref.child(user_group_path).removeValue()
                self.ref.child(group_user_path).removeValue()
                
                self.tableView.reloadData()
                
                tableView.setEditing(false, animated: true)
                
            }))
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                // Don't leave group
                print("Handle Cancel Logic here")
                
                confirmAlert.dismiss(animated: true, completion: nil)
                
                tableView.setEditing(false, animated: true)
            }))
            
            self.present(confirmAlert, animated: true, completion: nil)
            
            
            
            
        }
        leave.backgroundColor = UIColor(red: 249.0/255.0, green: 24.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped")
            
            self.indexOfRowSwipe = index.row
            
            self.performSegue(withIdentifier: "edit", sender: self)
            
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
        else if segue.identifier == "addMember"
        {
            let destVC = segue.destination as! AddGroupMemberViewController
            
            destVC.groupKey = self.userGroupsKeys[indexOfRowSwipe]
            destVC.groupName = self.userGroups[indexOfRowSwipe]
            
        }
        else if segue.identifier == "edit"
        {
            let destVC = segue.destination as! EditGroupViewController
            //print(self.userGroups)
            //print(self.userGroupsKeys)
            print(indexOfRowSwipe)
            destVC.groupKey = self.userGroupsKeys[indexOfRowSwipe]
            destVC.groupName = self.userGroups[indexOfRowSwipe]
        }
    }
    

}
