//
//  ArticleViewController.swift
//  artix
//
//  Created by Steven Rachesky on 3/31/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase

class ArticleViewController: UIViewController {

    //Firebase reference
    var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var copyView: UIView!
    @IBOutlet weak var addURL: DesignableButton!
    @IBOutlet weak var noAddURL: DesignableButton!
    @IBOutlet weak var urlLabel: UILabel!
    let pasteboard = UIPasteboard.general
    
    var name = ""
    var group = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        copyView.isHidden = true
        
        let path = "groups/" + self.group
        
        var urlList : [String] = []
        
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() == true
            {
                let articlesDict = snapshot.value! as! NSDictionary
                
                for child in articlesDict
                {
                    let childDic = child.value as? NSDictionary
                    
                    urlList.append(childDic?["url"] as! String)
                }
            }
        
        
        if (self.pasteboard.hasURLs && urlList.contains((self.pasteboard.url?.absoluteString)!) == false) {
            print("The pasteboard has URLs!")
            
            self.copyView.isHidden = false
            self.urlLabel.text? = (self.pasteboard.url?.absoluteString)!
        }
            
        })
        
        print("Article Scene: ")
        print(self.name)
        print(self.group)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchAddURL(_ sender: Any) {
        
        let path = "groups/" + self.group
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        let dateString = dateFormatter.string(from: date)
        
        let post = ["Name": self.name, "url":self.urlLabel.text!, "date": dateString]
        
        self.ref.child(path).childByAutoId().setValue(post)
        
        let articleList = self.childViewControllers[0] as! ArticleListTableViewController
        articleList.tableView.reloadData()
        articleList.viewWillAppear(true)
        
        copyView.isHidden = true

    }

    @IBAction func didTouchNoAddURL(_ sender: Any) {
        
        copyView.isHidden = true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "table"
        {
            let destVC = segue.destination as! ArticleListTableViewController
            destVC.name = self.name
            destVC.group = self.group
        }
        
        if segue.identifier == "plus"
        {
            let destVC = segue.destination as! AddArticleViewController
            destVC.group = self.group
            destVC.name = self.name
        }
    }
    

}
