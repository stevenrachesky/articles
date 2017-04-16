//
//  GroupMemberViewController.swift
//  
//
//  Created by Steven Rachesky on 4/15/17.
//
//

import UIKit
import Contacts
import Firebase



class GroupMemberViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var groupName = ""
    
    var store = CNContactStore()
    var contacts: [CNContact] = []
    var memberDict = [String: String]()
    var userName = ""
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()
    var userID = FIRAuth.auth()?.currentUser?.uid

    @IBOutlet weak var addedNamesTextView: UITextView!
    @IBOutlet var tableView: UITableView!


    @IBOutlet weak var phoneNumberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print(groupName)
        
        AppDelegate.sharedDelegate().checkAccessStatus(completionHandler: { (accessGranted) -> Void in
            print(accessGranted)
        })
        
        // add user to memberDict
        let userPhonePath = "users/" + userID! + "/phoneNumber"
        self.ref.child(userPhonePath).observeSingleEvent(of: .value, with: { (snapshot) in
          
            let user_phone = snapshot.value!
            
            let userNamePath = "users/" + self.userID! + "/fullName"
            
            self.ref.child(userNamePath).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.userName = snapshot.value! as! String
                
                self.memberDict[(user_phone as! String)] = self.userName
                
            })
            
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findContactsWithName(name: String) {
        AppDelegate.sharedDelegate().checkAccessStatus(completionHandler: { (accessGranted) -> Void in
            //print("3")
            if accessGranted {
                DispatchQueue.main.async(execute: { () -> Void in
                    do {
                        //print("2")
                        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: name)
                        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContact.descriptorForAllComparatorKeys()] as [Any] //CNContactViewController.descriptorForRequiredKeys()]
                        
                        self.contacts = try self.store.unifiedContacts(matching: predicate, keysToFetch:keysToFetch as! [CNKeyDescriptor])
                        self.tableView.reloadData()
                        
                    }
                    catch {
                        print("Unable to refetch the selected contact.")
                    }
                })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of cells is: ")
        print(self.contacts.count)
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "contact"
        //print("cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        cell.textLabel!.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
        
        let numbers = contacts[indexPath.row].phoneNumbers
            //[0].value as! CNPhoneNumber
            //.value(forKey: "digits")
        //print(numbers)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        
        let name = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
        let numbers = contacts[indexPath.row].phoneNumbers
        let text_ = addedNamesTextView.text
        
        if numbers.isEmpty == false
        {
            print("There are phone numbers!")
            
            if let number = (numbers[0].value as! CNPhoneNumber).value(forKey: "digits")
            {
                print(number)
                memberDict[(number as! String)] = name
                self.addedNamesTextView.text = text_! + name + ", "
            }
        }
        else
        {
            let message_ = "Sorry, we could not add " + name + " because you don't have a phone number saved"
            let alert = UIAlertController(title: "No Phone Number", message: message_, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(memberDict)
        
    }
    
    
    @IBAction func textFieldEditChanged(_ sender: Any) {
        //print("edit changed")
        if let query = self.phoneNumberTextField.text {
            //print("1")
            self.findContactsWithName(name: query)
        }
    }
    
    @IBAction func doneDidTouch(_ sender: Any) {
        
        let groupID = self.ref.child("groups").childByAutoId().key
        
        for member in memberDict
        {
            print(member)
            // member variables
            var memberID = ""
            
            // clean phone numbrer
            var phoneNumber = member.key
            phoneNumber = phoneNumber.trimmingCharacters(in: NSCharacterSet(charactersIn: "+") as CharacterSet)
            let first_character = phoneNumber.substring(to: phoneNumber.index(after: phoneNumber.startIndex))
            if first_character == "1"
            {
                phoneNumber.remove(at: phoneNumber.startIndex)
            }
            print(phoneNumber)
            
            var phone_path = "phoneNumbers/" + phoneNumber
            
            // get members ID
            self.ref.child(phone_path).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists() == true
                {
                    let snapDict = snapshot.value! as! NSDictionary
                    memberID = snapDict.value(forKey: "userID") as! String
                }
                else
                {
                    memberID = self.ref.child(phone_path).childByAutoId().key
                    let post = ["userID": memberID]
                    self.ref.child(phone_path).setValue(post)
                }
                
                // add group to user section
                var user_group_path = "users/" + memberID + "/groups/" + groupID
                var user_path = "users/" + memberID
                
                //check if user exists
                self.ref.child(user_path).observeSingleEvent(of: .value, with: { (snapshot) in
                  
                    
                    if snapshot.exists() == true
                    {
                       // user exists, add group
                        self.ref.child(user_group_path).setValue(self.groupName)
                    }
                    else
                    {
                        // user does not exist
                        // add group name to phone section for future user to log in
                        print("Error: user must not exist")
                        let phone_group_path = phone_path + "/groups/" + groupID
                        self.ref.child(phone_group_path).setValue(self.groupName)
                    }
                    
                    // perform segue - done with all firebase
                    self.performSegue(withIdentifier: "addedGroup", sender: self)
                    
                })
                
            })
            
        }
        
    }

    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addedGroup"
        {
//            let destVC = segue.destination as! MainTabBarController
//            destVC.name = self.userName
        }
        
    }
    

}
