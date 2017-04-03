//
//  ArticleListTableViewController.swift
//  artix
//
//  Created by Steven Rachesky on 3/27/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase
import ReadabilityKit

class ArticleListTableViewController: UITableViewController {
    
    var name = ""
    var group = ""
    var articlesURL : [String] = []
    var articlesName : [String] = []
    var articlesDate : [NSDate] = []
    var articlesTitle : [String] = []
    var articlesImage : [UIImage] = []
    
    // Readability variables
    var url: URL?
    var parser: Readability?
    var image: UIImage?
    var parsedData: ReadabilityData?
    
    //Firebase reference
    var ref = FIRDatabase.database().reference()
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.tableView.reloadData()
        
        self.articlesURL = []
        self.articlesName = []
        self.articlesDate = []
        
        let path = "groups/" + self.group
        
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() == true
            {
                let articlesDict = snapshot.value! as! NSDictionary
                
                for child in articlesDict
                {
                    let childDic = child.value as? NSDictionary
                    
                    self.articlesURL.append(childDic?["url"] as! String)
                    self.articlesName.append(childDic?["Name"] as! String)
                    
                    let dateString = childDic?["date"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                    let articleDate = dateFormatter.date(from: dateString)
                    
                    self.articlesDate.append(articleDate! as NSDate)
                    
                    //self.articlesDateString.append()
                    
                    //print(childDic)
                }
                
            }
            else
            {
                let alert = UIAlertController(title: "No Articles", message: "Sorry, we did not find any articles in this group.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            //print(self.articlesDate)
            //print("_")
            let sortedArticlesDate = self.articlesDate.sorted(by: { $0.compare($1 as Date) == .orderedDescending})
            //print(sortedArticlesDate)
            //print(self.articlesURL)
            //print("___")
            
            let result = zip(zip(self.articlesDate, self.articlesName), self.articlesURL).map { ($0.0.0, $0.0.1, $0.1) }.sorted(by: { $0.0.compare($1.0 as Date) == .orderedDescending})
            //print(result)
            
            self.articlesName = result.map { $0.1 }
            self.articlesURL = result.map { $0.2 }
            
            
            
            self.tableView.reloadData()
            
        })
        
        self.tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        
        print("Article List: ")
        print(self.name)
        print(self.group)
        
        self.tableView.reloadData()
        
        
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
        print(self.articlesName.count)
        return self.articlesName.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "urlReadability", for: indexPath) as! ArticlesReadabilityTableViewCell

        // Configure the cell...
        //cell.url.text! = self.articlesURL[(indexPath as NSIndexPath).item]
        
        var articleTitle = ""
        var articleImage = UIImage()
            
            self.url = URL(string: self.articlesURL[(indexPath as NSIndexPath).item])
            
            Readability.parse(url: self.url!) { data in
                
                self.parsedData = data
                
                guard let imageUrlStr = data?.topImage else {
                    return
                }
                
                guard let imageUrl = URL(string: imageUrlStr) else {
                    return
                }
                
                guard let imageData = try? Data(contentsOf: imageUrl) else {
                    return
                }
                
                articleTitle = (data?.title)!
                
                articleImage = UIImage(data: imageData)!
                
                print(articleTitle)
            
        if articleTitle == ""
        {
            articleTitle = self.articlesURL[(indexPath as NSIndexPath).item]
        }
        
        cell.articleTitle.text! = articleTitle
        cell.articleImage.image = articleImage
        cell.articleButton.setTitle(self.articlesName[(indexPath as NSIndexPath).item], for: .normal)
        cell.tag = (indexPath as NSIndexPath).row
        
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "Save to Personal") { action, index in
            print("more button tapped")
            
            let path = "users/" + self.name + "/personalList"
            
            let date = Date()
            print(date)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
            let dateString = dateFormatter.string(from: date)
            
            let post = ["Name": self.articlesName[(index as NSIndexPath).item], "url":self.articlesURL[(index as NSIndexPath).item], "date": dateString]
            
            self.ref.child(path).childByAutoId().setValue(post)
            
            tableView.setEditing(false, animated: true)
        }
        more.backgroundColor = UIColor(red: 2.0/255.0, green: 179.0/255.0, blue: 1.0, alpha: 1.0)
        
        
        
        return [more]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        
        
        if let url = URL(string: self.articlesURL[indexPath.row])
        {
            UIApplication.shared.openURL(url)
        }
        else
        {
            let alert = UIAlertController(title: "Invalid URL", message: "Sorry, we could not open that url.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
