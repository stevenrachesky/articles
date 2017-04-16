//
//  PersonalListTableViewController.swift
//  artix
//
//  Created by Steven Rachesky on 3/27/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit
import Firebase
import ReadabilityKit

class PersonalListTableViewController: UITableViewController {
    
    
    var numRows = 5
    var name = ""
    var articlesURL : [String] = []
    var articlesName : [String] = []
    var articlesKeys : [String] = []
    var articlesDate : [NSDate] = []
    var articlesTitle : [String] = []
    var articlesImage : [UIImage] = []
    var colorDict = [String : UIColor]()

    //Firebase reference
    var ref = FIRDatabase.database().reference()
    var userID = FIRAuth.auth()?.currentUser?.uid
    
    // Readability variables
    var url: URL?
    var parser: Readability?
    var image: UIImage?
    var parsedData: ReadabilityData?
    
    override func viewWillAppear(_ animated: Bool) {
        
//        self.indicator.startAnimating()
//        self.indicator.backgroundColor = UIColor.black
        
        //self.tableView.reloadData()
        print("viewWillAppear Began")
        
        let path = "users/" + userID! + "/personalList"
        
        self.ref.child(path).observeSingleEvent(of: .value, with: { (snapshot) in
            print("BOUT TO REFRESH ARTICLES")
            self.articlesKeys = []
            self.articlesURL = []
            self.articlesName = []
            self.articlesDate = []
            self.colorDict = [String : UIColor]()
            self.articlesTitle = []
            
            if snapshot.exists() == true
            {
                let articlesDict = snapshot.value! as! NSDictionary
                
                for child in articlesDict
                {
                    let childDic = child.value as? NSDictionary
                    
                    self.articlesURL.append(childDic?["url"] as! String)
                    self.articlesName.append(childDic?["Name"] as! String)
                    if let a_title = childDic?["title"] as! String!
                    {
                        self.articlesTitle.append(a_title)
                    }
                    else
                    {
                        self.articlesTitle.append(childDic?["url"] as! String)
                    }
                    
                    let dateString = childDic?["date"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
                    let articleDate = dateFormatter.date(from: dateString)
                    
                    self.articlesDate.append(articleDate! as NSDate)
                    
                }
                
                self.articlesKeys = articlesDict.allKeys as! [String]
                let uniqueNames = Array(Set(self.articlesName))
                for uname in uniqueNames
                {
                    self.colorDict[uname] = self.getRandomColor()
                }
                
            }
            else
            {
                let alert = UIAlertController(title: "No Articles", message: "Sorry, we did not find any articles in your personal section.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }


            
            let result = zip(zip(zip(zip(self.articlesDate, self.articlesName), self.articlesURL), self.articlesTitle), self.articlesKeys).map { ($0.0.0.0.0, $0.0.0.0.1, $0.0.0.1, $0.0.1, $0.1) }.sorted(by: { $0.0.compare($1.0 as Date) == .orderedDescending})
            
            self.articlesName = result.map { $0.1 }
            self.articlesURL = result.map { $0.2 }
            self.articlesTitle = result.map {$0.3}
            self.articlesKeys = result.map {$0.4}
            
//            print("name should be: ")
//            print(self.articlesName)
//            print("url should be: ")
//            print(self.articlesURL)
//            print("title should be: ")
//            print(self.articlesTitle)
//            print("keys should be: ")
//            print(self.articlesKeys)
            
            
            self.tableView.reloadData()
            
            print("viewWillAppear Loaded")
            
        })
        //self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()


        
        
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
        return self.articlesName.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "urlReadability", for: indexPath) as! ArticlesReadabilityTableViewCell

        // Configure the cell...
        //cell.url.text! = self.articlesURL[(indexPath as NSIndexPath).item]
        
        let userName = self.articlesName[(indexPath as NSIndexPath).item]
        
        cell.articleButton.borderColor = self.colorDict[userName]!
        cell.articleButton.setTitleColor(self.colorDict[userName]!, for: .normal)
        
        var articleTitle = self.articlesTitle[(indexPath as NSIndexPath).item]
        var articleImage :UIImage? = nil //UIImage()
        cell.articleImage.image = nil
        
        print(indexPath.item)
        
        if let url_ = URL(string: self.articlesURL[(indexPath as NSIndexPath).item])
        {
            
            Readability.parse(url: url_) { data in
                print("URL is not nil: ")
                print(url_)
                self.parsedData = data
                
                guard let imageUrlStr = data?.topImage else {
                    
                    print("no image found")
                    articleTitle = self.articlesURL[(indexPath as NSIndexPath).item]
                    cell.articleTitle.text! = articleTitle
                    cell.articleImage.image = nil
                    
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
                
                //articleTitle = (data?.title)!
                //print(articleTitle)
                articleImage = UIImage(data: imageData)!
                
                cell.articleImage.image = articleImage
                
            }
        }
        else
        {

        }
        
        cell.articleTitle.text! = articleTitle
        cell.articleButton.setTitle(self.articlesName[(indexPath as NSIndexPath).item], for: .normal)
        cell.tag = (indexPath as NSIndexPath).row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        
    
        if let url = URL(string: self.articlesURL[indexPath.row])
        {
            UIApplication.shared.openURL(url)
            tableView.deselectRow(at: indexPath, animated: true)

        }
        else
        {
            let alert = UIAlertController(title: "Invalid URL", message: "Sorry, we could not open that url.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)

        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.articlesName.remove(at: (indexPath.item))
            self.articlesURL.remove(at: (indexPath.item))
            self.articlesTitle.remove(at: indexPath.item)
            self.articlesDate.remove(at: indexPath.item)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            var path = "users/" + userID! + "/personalList"
            
            ref.child(path).child(self.articlesKeys[indexPath.item]).removeValue()
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func getRandomColor() -> UIColor{
        //Generate between 0 to 1
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
    

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
