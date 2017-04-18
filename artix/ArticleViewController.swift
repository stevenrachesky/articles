//
//  ArticleViewController.swift
//  artix
//
//  Created by Steven Rachesky on 3/31/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase
import ReadabilityKit

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
    
    // Readability variables
    var parser: Readability?
    var url: URL?
    var image: UIImage?
    var parsedData: ReadabilityData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        copyView.isHidden = true
        
        let path = "groups/" + self.group + "/articles"
        
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
//        print(self.name)
//        print(self.group)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchAddURL(_ sender: Any) {
        
        let path = "groups/" + self.group + "/articles"
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        let dateString = dateFormatter.string(from: date)
        
        var articleTitle = ""
        
        if let url_ = URL(string: self.urlLabel.text!)
        {
            Readability.parse(url: url_) { data in
                print("URL is not nil: ")
                print(url_)
                self.parsedData = data
                
                guard let imageUrlStr = data?.topImage else {
                    
                    print("no image found")
                    articleTitle = self.urlLabel.text!
                    
                    let post = ["Name": self.name, "url":self.urlLabel.text!, "date": dateString, "title": articleTitle]
                    
                    self.ref.child(path).childByAutoId().setValue(post)
                    
                    
                    let articleList = self.childViewControllers[0] as! ArticleListTableViewController
                    //articleList.tableView.reloadData()
                    articleList.viewWillAppear(true)
                    
                    self.copyView.isHidden = true
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
                    articleTitle = self.urlLabel.text!
                }
                print("title in post \(articleTitle)")
                let post = ["Name": self.name, "url":self.urlLabel.text!, "date": dateString, "title": articleTitle]
                
                self.ref.child(path).childByAutoId().setValue(post)
                
                
                let articleList = self.childViewControllers[0] as! ArticleListTableViewController
                //articleList.tableView.reloadData()
                articleList.viewWillAppear(true)
                
                self.copyView.isHidden = true
            }
        }
        else
        {
            articleTitle = self.urlLabel.text!
            print("title in post \(articleTitle)")
            let post = ["Name": self.name, "url":self.urlLabel.text!, "date": dateString, "title": articleTitle]
            
            self.ref.child(path).childByAutoId().setValue(post)
            
            
            let articleList = self.childViewControllers[0] as! ArticleListTableViewController
            articleList.tableView.reloadData()
            articleList.viewWillAppear(true)
            
            self.copyView.isHidden = true
        }
        



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
