//
//  ALockTableViewCell.swift
//  VanguardLock
//
//  Created by Michael Nguyen on 12/8/16.
//  Copyright © 2016 Michael Nguyen. All rights reserved.
//

import UIKit

class ALockTableViewCell: UITableViewCell {

    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var lockImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
