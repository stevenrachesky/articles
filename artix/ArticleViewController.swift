//
//  ArticleViewController.swift
//  artix
//
//  Created by Steven Rachesky on 3/31/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {


    @IBOutlet weak var copyView: UIView!
    @IBOutlet weak var addURL: DesignableButton!
    @IBOutlet weak var noAddURL: DesignableButton!
    @IBOutlet weak var urlLabel: UILabel!
    let pasteboard = UIPasteboard.general
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        copyView.isHidden = true
        
        if pasteboard.hasURLs {
            print("The pasteboard has URLs!")
            
            copyView.isHidden = false
            urlLabel.text? = (pasteboard.url?.absoluteString)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchAddURL(_ sender: Any) {
        
        copyView.isHidden = true

    }

    @IBAction func didTouchNoAddURL(_ sender: Any) {
        
        copyView.isHidden = true
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
