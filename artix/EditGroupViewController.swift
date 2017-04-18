//
//  EditGroupViewController.swift
//  artix
//
//  Created by Steven Rachesky on 4/18/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class EditGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var groupName = ""
    var groupKey = ""
    var memberNames : [String] = []
    var memberKeys : [String] = []

    //Firebase reference
    var ref = FIRDatabase.database().reference()
    var userID = FIRAuth.auth()?.currentUser?.uid
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameTextField: DesignableTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupNameTextField.text = groupName
        
        let group_members_path = "groups/" + groupKey + "/members"
        self.ref.child(group_members_path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var groupMembersDict = snapshot.value as! NSDictionary
            
            for member in groupMembersDict
            {
                let memberName = member.value as! String
                let memberKey = member.key as! String
                
                self.memberNames.append(memberName)
                self.memberKeys.append(memberKey)
                
            }
            self.tableView.reloadData()
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.memberNames.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "member"

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        cell.textLabel!.text = self.memberNames[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            print("remove button tapped at \(index.row)")
            
            let memberName = self.memberNames[index.row]
            let memberKey = self.memberKeys[index.row]
            
            let group_remove_path = "groups/" + self.groupKey + "/members/" + memberKey
            
            let user_remove_path = "users/" + memberKey + "/groups/" + self.groupKey
            
            let message = memberName + " will lose access to this group."
            let confirmAlert = UIAlertController(title: "Are you sure?", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                // Yes leave group
                print("Handle Yes logic here")
                
                self.memberNames.remove(at: index.row)
                self.memberKeys.remove(at: index.row)
                
                self.ref.child(group_remove_path).removeValue()
                self.ref.child(user_remove_path).removeValue()
                
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
        remove.backgroundColor = UIColor(red: 249.0/255.0, green: 24.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        
        return [remove]
    }
    

    @IBAction func doneButtonDidTouch(_ sender: Any) {
        
        if groupName != self.groupNameTextField.text!
        {
            
            for key in memberKeys
            {
                let user_group_path = "users/" + key + "/groups/" + self.groupKey
                self.ref.child(user_group_path).setValue(self.groupNameTextField.text!)
            }
        }
        
        self.performSegue(withIdentifier: "doneEditGroup", sender: self)
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
