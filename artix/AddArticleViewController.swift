//
//  AddArticleViewController.swift
//  artix
//
//  Created by Steven Rachesky on 4/1/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase
import ReadabilityKit

class AddArticleViewController: UIViewController {

    var group = ""
    var name = ""
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()
    
    // Readability variables
    var parser: Readability?
    var url: URL?
    var image: UIImage?
    var parsedData: ReadabilityData?
    
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
        //print(date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        let dateString = dateFormatter.string(from: date)
        
        if urlTextField.text! != ""
        {
            var articleTitle = ""
            
            if let url_ = URL(string: self.urlTextField.text!)
            {
                Readability.parse(url: url_) { data in
                    print("URL is not nil: ")
                    print(url_)
                    self.parsedData = data
                    
                    guard let imageUrlStr = data?.topImage else {
                        
                        print("no image found")
                        articleTitle = self.urlTextField.text!
                        return
                    }
                    
                    guard let imageUrl = URL(string: imageUrlStr) else {
                        print("no 2")
                        return
                    }
                    
                    guard let imageData = try? Data(contentsOf: imageUrl) else {
                        print("no 3")
                        return
                    }
                    
                    articleTitle = (data?.title)!
                    //print(articleTitle)
                    
                    if (articleTitle == "")
                    {
                        print("articles title is empty")
                        articleTitle = self.urlTextField.text!
                    }
                    let post = ["Name": self.name, "url":self.urlTextField.text!, "date": dateString, "title": articleTitle]
                    
                    self.ref.child(path).childByAutoId().setValue(post)
                    
                }
            }
            else
            {
                articleTitle = self.urlTextField.text!
                let post = ["Name": self.name, "url":self.urlTextField.text!, "date": dateString, "title": articleTitle]
                
                self.ref.child(path).childByAutoId().setValue(post)
                
            }
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
