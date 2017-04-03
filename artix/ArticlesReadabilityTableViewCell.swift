//
//  ArticlesReadabilityTableViewCell.swift
//  artix
//
//  Created by Steven Rachesky on 4/2/17.
//  Copyright © 2017 Rachesky-Brown. All rights reserved.
//

import UIKit

class ArticlesReadabilityTableViewCell: UITableViewCell {

    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleButton: DesignableButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
